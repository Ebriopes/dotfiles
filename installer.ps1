# Configura el HOME del usuario usando un repositorio Git bare en PowerShell.

# Configuración de manejo de errores: detiene el script en caso de error.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# --- Variables Globales ---
$HOME_CFG = Join-Path $HOME ".cfg" # Ruta para el repositorio bare.
$CONFIG_BACKUP = Join-Path $HOME ".config\backup" # Ruta para el backup.
$GIT_BIN = "git" # El comando 'git' debe estar en el PATH.
# En PowerShell, el perfil del usuario es el archivo de configuración de la shell.
$SHELL_CONFIG_FILE = $PROFILE
$DOTFILES_GIT_FUNCTION_NAME = "dotfiles-git" # Nuevo nombre para la función alias de Git

# --- Funciones ---

# Función para ejecutar comandos de git en el repositorio bare.
# Esta función es para comandos que operan *dentro* del repositorio bare ya creado.
function Invoke-GitConfig {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string[]]$Arguments
    )
    # Asegúrate de que $GIT_BIN esté disponible en el PATH.
    & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" @Arguments
}

# Función para imprimir mensajes con color.
function Write-ColoredMessage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    switch ($Type) {
        "info" { Write-Host -ForegroundColor Green $Message }
        "warning" { Write-Host -ForegroundColor Yellow $Message }
        "error" {
            Write-Host -ForegroundColor Red $Message
            exit 1
        }
        default { Write-Host $Message }
    }
}

# Función para mostrar el menú y obtener la opción seleccionada.
function Show-Menu {
    Write-ColoredMessage -Type "info" "Configurando tu HOME desde el repositorio Git bare..."
    Write-Host "`n`e[1;33mMenú de Configuración de HOME`e[0m"
    Write-Host "1. Ejecutar el proceso completo automáticamente"
    Write-Host "2. Ejecutar paso a paso"
    Write-Host "3. Salir"

    $opcion = Read-Host -Prompt "Seleccione una opción"
    Write-Host "" # Nueva línea

    # Validación de la entrada.
    if (-not ($opcion -match "^[1-3]$")) {
        Write-ColoredMessage -Type "error" "Opción inválida. Saliendo del script."
    }

    Write-Host "Opción seleccionada: $opcion" # Mensaje de depuración
    return $opcion
}

# Función para respaldar o eliminar archivos.
function Handle-BackupFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$FilesToHandle # Array de rutas de archivos
    )

    if ($FilesToHandle.Length -gt 0) {
        Write-ColoredMessage -Type "warning" "Se encontraron archivos sin seguimiento que podrían ser sobrescritos."
        $respuesta = Read-Host -Prompt "¿Desea [r]espaldarlos, [e]liminarlos, o [a]bortar? (r/e/a)"
        Write-Host "" # Nueva línea

        switch ($respuesta.ToLower()) {
            "r" {
                Write-ColoredMessage -Type "info" "Respaldando archivos..."
                foreach ($file in $FilesToHandle) {
                    $sourcePath = Join-Path $HOME $file
                    $destinationPath = Join-Path $CONFIG_BACKUP $file
                    
                    # Asegurarse de que el directorio destino exista
                    $destinationDir = Split-Path $destinationPath -Parent
                    if (-not (Test-Path $destinationDir -PathType Container)) {
                        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
                    }

                    Write-ColoredMessage -Type "warning" "Respaldando $sourcePath en $destinationPath..."
                    try {
                        Move-Item -Path $sourcePath -Destination $destinationPath -Force
                        Write-ColoredMessage -Type "info" "$sourcePath respaldado exitosamente en $destinationPath"
                    } catch {
                        Write-ColoredMessage -Type "error" "No se pudo respaldar $sourcePath. Error: $($_.Exception.Message)"
                    }
                }
            }
            "e" {
                Write-ColoredMessage -Type "warning" "Eliminando archivos sin seguimiento..."
                foreach ($file in $FilesToHandle) {
                    $targetPath = Join-Path $HOME $file
                    Write-ColoredMessage -Type "warning" "Eliminando $targetPath..."
                    try {
                        Remove-Item -Path $targetPath -Recurse -Force
                        Write-ColoredMessage -Type "info" "$targetPath eliminado."
                    } catch {
                        Write-ColoredMessage -Type "error" "No se pudo eliminar $targetPath. Error: $($_.Exception.Message)"
                    }
                    # Si el archivo era un directorio y se eliminó, asegúrate de que no quede referencia
                    if (Test-Path $targetPath -PathType Container) {
                        # Esto es solo una precaución, Remove-Item -Recurse debería manejarlo
                    }
                }
            }
            "a" {
                Write-ColoredMessage -Type "error" "Operación abortada por el usuario."
            }
            default {
                Write-ColoredMessage -Type "error" "Opción inválida. Abortando."
            }
        }
    } else {
        Write-ColoredMessage -Type "info" "No hay archivos que respaldar o eliminar."
    }
}

# --- Lógica Principal del Script ---

# Mostrar el menú y obtener la opción del usuario.
$selectedOption = Show-Menu

# Ejecutar la opción seleccionada.
switch ($selectedOption) {
    "1" {
        Write-ColoredMessage -Type "info" "Ejecutando el proceso completo automáticamente..."

        # 1. Eliminar la configuración anterior (si existe).
        Write-ColoredMessage -Type "info" "Paso 1: Eliminar configuración anterior (si existe)."
        if (Test-Path $HOME_CFG -PathType Container) {
            Write-ColoredMessage -Type "warning" "Se ha encontrado una configuración anterior en $HOME_CFG."
            $respuesta = Read-Host -Prompt "¿Desea eliminarla? (s/n)"
            Write-Host "" # Nueva línea
            if ($respuesta.ToLower() -eq "s") {
                Write-ColoredMessage -Type "warning" "Eliminando configuración anterior en $HOME_CFG..."
                try {
                    Remove-Item -Path $HOME_CFG -Recurse -Force
                    Write-ColoredMessage -Type "info" "Configuración anterior eliminada."
                } catch {
                    Write-ColoredMessage -Type "error" "No se pudo eliminar la configuración anterior en $HOME_CFG. Error: $($_.Exception.Message)"
                }
            } else {
                Write-ColoredMessage -Type "warning" "La configuración anterior se mantendrá."
            }
        }

        # 2. Clonar o inicializar el repositorio bare.
        Write-ColoredMessage -Type "info" "Paso 2: Clonar o inicializar el repositorio bare."
        if (-not (Test-Path $HOME_CFG -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Clonando el repositorio bare en $HOME_CFG..."
            try {
                # Directamente usar git clone, sin Invoke-GitConfig, ya que no opera *dentro* de un repo existente.
                & $GIT_BIN clone --bare "https://github.com/Ebriopes/dotfiles.git" "$HOME_CFG"
                Write-ColoredMessage -Type "info" "Repositorio bare clonado exitosamente en $HOME_CFG."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo clonar el repositorio bare. Error: $($_.Exception.Message)"
            }
        } else {
             Write-ColoredMessage -Type "warning" "Inicializando un repositorio bare existente en $HOME_CFG..."
             try {
                 # Si el directorio ya existe, asumimos que es el repositorio bare.
                 Write-ColoredMessage -Type "info" "El directorio $HOME_CFG ya existe. Asumiendo que es el repositorio bare."
             } catch {
                 Write-ColoredMessage -Type "error" "No se pudo inicializar el repositorio bare. Error: $($_.Exception.Message)"
             }
        }


        # 3. Crear un alias para el comando git (en PowerShell, es una función o alias de PowerShell)
        Write-ColoredMessage -Type "info" "Paso 3: Configurar alias para el comando git..."
        # El archivo de perfil de PowerShell es la ubicación estándar para alias/funciones.
        if (-not (Test-Path $SHELL_CONFIG_FILE)) {
            New-Item -Path $SHELL_CONFIG_FILE -ItemType File -Force | Out-Null
        }

        # Usar el nuevo nombre de la función
        $aliasContent = "function $($DOTFILES_GIT_FUNCTION_NAME) { & git --git-dir='$HOME_CFG/' --work-tree='$HOME' `$args }"
        # Usar Select-String con -Raw para buscar la línea completa y evitar problemas con caracteres especiales
        if (-not (Get-Content $SHELL_CONFIG_FILE -Raw | Select-String -Pattern "^function $($DOTFILES_GIT_FUNCTION_NAME) {" -Quiet)) {
            try {
                Add-Content -Path $SHELL_CONFIG_FILE -Value $aliasContent
                Write-ColoredMessage -Type "info" "Función '$($DOTFILES_GIT_FUNCTION_NAME)' agregada a $SHELL_CONFIG_FILE. Reinicia PowerShell para que tenga efecto."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo agregar la función '$($DOTFILES_GIT_FUNCTION_NAME)' a $SHELL_CONFIG_FILE. Error: $($_.Exception.Message)"
            }
        } else {
            Write-ColoredMessage -Type "warning" "La función '$($DOTFILES_GIT_FUNCTION_NAME)' ya existe en $SHELL_CONFIG_FILE. No se modificará."
        }

        # 4. Desactivar el seguimiento de archivos no rastreados.
        Write-ColoredMessage -Type "info" "Paso 4: Desactivar el seguimiento de archivos no rastreados."
        Write-ColoredMessage -Type "warning" "Desactivando el seguimiento de archivos no rastreados..."
        try {
            # Llamar directamente a git config con los parámetros --git-dir y --work-tree
            & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" config status.showUntrackedFiles no
            Write-ColoredMessage -Type "info" "No tracking files."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo desactivar el seguimiento de archivos no rastreados. Error: $($_.Exception.Message)"
        }

        # 5. Crear el directorio de respaldo (si no existe).
        Write-ColoredMessage -Type "info" "Paso 5: Crear el directorio de respaldo."
        if (-not (Test-Path $CONFIG_BACKUP -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Creando directorio de respaldo en $CONFIG_BACKUP..."
            try {
                New-Item -ItemType Directory -Path $CONFIG_BACKUP -Force | Out-Null
                Write-ColoredMessage -Type "info" "Directorio de respaldo creado exitosamente en $CONFIG_BACKUP."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo crear el directorio de respaldo. Error: $($_.Exception.Message)"
            }
        }

        # 6. Respaldar archivos de configuración.
        Write-ColoredMessage -Type "info" "Paso 6: Respaldar archivos de configuración."
        Write-ColoredMessage -Type "warning" "Respaldando archivos de configuración en $CONFIG_BACKUP..."

        # --- CORRECCIÓN AQUÍ: Manejo más robusto de la salida de git checkout ---
        $gitCheckoutOutput = ""
        $gitExitCode = 0
        try {
            # Ejecutar git checkout y capturar la salida y el código de salida.
            # El 2>&1 redirige stderr a stdout, y Out-String lo captura como una sola cadena.
            # El bloque script { ... } permite que $ErrorActionPreference no detenga la ejecución aquí.
            $gitCheckoutResult = & {
                & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" checkout 2>&1
            }
            $gitCheckoutOutput = $gitCheckoutResult | Out-String
            $gitExitCode = $LASTEXITCODE # Captura el código de salida del último comando externo
        } catch {
            # Esto atraparía errores de PowerShell si el comando git no se encuentra, etc.
            Write-ColoredMessage -Type "error" "Error inesperado al ejecutar 'git checkout' para obtener la lista de archivos: $($_.Exception.Message)"
            exit 1
        }

        $backupFilesList = @()
        $inUntrackedSection = $false
        $isExpectedGitWarning = $false

        # Verificar si la salida contiene la advertencia esperada de Git
        if ($gitCheckoutOutput -match "error: The following untracked working tree files would be overwritten by checkout:") {
            $isExpectedGitWarning = $true
            # Procesar la salida para extraer los nombres de los archivos
            foreach ($line in ($gitCheckoutOutput -split "`n")) {
                if ($line -match "error: The following untracked working tree files would be overwritten by checkout:") {
                    $inUntrackedSection = $true
                    continue
                }
                if ($inUntrackedSection -and $line -match "^\s+\./(.+)$") {
                    $backupFilesList += $Matches[1].Trim()
                } elseif ($inUntrackedSection -and $line.Trim() -eq "") {
                    break
                }
            }
        }
        
        # Si Git salió con un código de error Y NO es la advertencia esperada, entonces es un error real.
        if ($gitExitCode -ne 0 -and -not $isExpectedGitWarning) {
            Write-ColoredMessage -Type "error" "Error inesperado de Git al obtener la lista de archivos: $($gitCheckoutOutput)"
        } elseif ($backupFilesList.Length -gt 0) {
            # Si hay archivos para respaldar (ya sea por la advertencia esperada o por otros motivos)
            Handle-BackupFiles -FilesToHandle $backupFilesList
        } else {
            Write-ColoredMessage -Type "info" "No hay archivos que respaldar o eliminar."
        }
        # --- FIN CORRECCIÓN ---

        # 7. Hacer checkout de la configuración.
        Write-ColoredMessage -Type "info" "Paso 7: Hacer checkout de la configuración."
        Write-ColoredMessage -Type "warning" "Haciendo checkout de la configuración..."
        try {
            Invoke-GitConfig checkout | Out-Null # Suprimimos la salida
            Write-ColoredMessage -Type "info" "Configuración aplicada exitosamente."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo hacer checkout de la configuración. Por favor, revisa si hay conflictos manualmente. Error: $($_.Exception.Message)"
        }

        Write-ColoredMessage -Type "info" "¡Configuración de HOME completada!"
    }
    "2" {
        Write-ColoredMessage -Type "info" "Ejecutando el proceso paso a paso. Por favor, siga las instrucciones:"

        # 1. Eliminar la configuración anterior (si existe).
        Write-ColoredMessage -Type "info" "Paso 1: Eliminar configuración anterior (si existe)."
        if (Test-Path $HOME_CFG -PathType Container) {
            Write-ColoredMessage -Type "warning" "Se ha encontrado una configuración anterior en $HOME_CFG."
            $respuesta = Read-Host -Prompt "¿Desea eliminarla? (s/n)"
            Write-Host "" # Nueva línea
            if ($respuesta.ToLower() -eq "s") {
                Write-ColoredMessage -Type "warning" "Eliminando configuración anterior en $HOME_CFG..."
                try {
                    Remove-Item -Path $HOME_CFG -Recurse -Force
                    Write-ColoredMessage -Type "info" "Configuración anterior eliminada."
                } catch {
                    Write-ColoredMessage -Type "error" "No se pudo eliminar la configuración anterior en $HOME_CFG. Error: $($_.Exception.Message)"
                }
            } else {
                Write-ColoredMessage -Type "warning" "La configuración anterior se mantendrá."
            }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 2..." | Out-Null

        # 2. Clonar o inicializar el repositorio bare.
        Write-ColoredMessage -Type "info" "Paso 2: Clonar o inicializar el repositorio bare."
        if (-not (Test-Path $HOME_CFG -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Clonando el repositorio bare en $HOME_CFG..."
            try {
                # Directamente usar git clone, sin Invoke-GitConfig
                & $GIT_BIN clone --bare "https://github.com/Ebriopes/dotfiles.git" "$HOME_CFG"
                Write-ColoredMessage -Type "info" "Repositorio bare clonado exitosamente en $HOME_CFG."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo clonar el repositorio bare. Error: $($_.Exception.Message)"
            }
        } else {
             Write-ColoredMessage -Type "warning" "Inicializando un repositorio bare existente en $HOME_CFG..."
             try {
                 Write-ColoredMessage -Type "info" "El directorio $HOME_CFG ya existe. Asumiendo que es el repositorio bare."
             } catch {
                 Write-ColoredMessage -Type "error" "No se pudo inicializar el repositorio bare. Error: $($_.Exception.Message)"
             }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 3..." | Out-Null

        # 3. Crear un alias para el comando git (en PowerShell, es una función o alias de PowerShell)
        Write-ColoredMessage -Type "info" "Paso 3: Configurar alias para el comando git..."
        if (-not (Test-Path $SHELL_CONFIG_FILE)) {
            New-Item -ItemType File -Force | Out-Null
        }

        # Usar el nuevo nombre de la función
        $aliasContent = "function $($DOTFILES_GIT_FUNCTION_NAME) { & git --git-dir='$HOME_CFG/' --work-tree='$HOME' `$args }"
        # Usar Select-String con -Raw para buscar la línea completa y evitar problemas con caracteres especiales
        if (-not (Get-Content $SHELL_CONFIG_FILE -Raw | Select-String -Pattern "^function $($DOTFILES_GIT_FUNCTION_NAME) {" -Quiet)) {
            try {
                Add-Content -Path $SHELL_CONFIG_FILE -Value $aliasContent
                Write-ColoredMessage -Type "info" "Función '$($DOTFILES_GIT_FUNCTION_NAME)' agregada a $SHELL_CONFIG_FILE. Reinicia PowerShell para que tenga efecto."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo agregar la función '$($DOTFILES_GIT_FUNCTION_NAME)' a $SHELL_CONFIG_FILE. Error: $($_.Exception.Message)"
            }
        } else {
            Write-ColoredMessage -Type "warning" "La función '$($DOTFILES_GIT_FUNCTION_NAME)' ya existe en $SHELL_CONFIG_FILE. No se modificará."
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 4..." | Out-Null

        # 4. Desactivar el seguimiento de archivos no rastreados.
        Write-ColoredMessage -Type "info" "Paso 4: Desactivar el seguimiento de archivos no rastreados."
        Write-ColoredMessage -Type "warning" "Desactivando el seguimiento de archivos no rastreados..."
        try {
            & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" config status.showUntrackedFiles no
            Write-ColoredMessage -Type "info" "No tracking files."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo desactivar el seguimiento de archivos no rastreados. Error: $($_.Exception.Message)"
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 5..." | Out-Null

        # 5. Crear el directorio de respaldo (si no existe).
        Write-ColoredMessage -Type "info" "Paso 5: Crear el directorio de respaldo."
        if (-not (Test-Path $CONFIG_BACKUP -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Creando directorio de respaldo en $CONFIG_BACKUP..."
            try {
                New-Item -ItemType Directory -Path $CONFIG_BACKUP -Force | Out-Null
                Write-ColoredMessage -Type "info" "Directorio de respaldo creado exitosamente en $CONFIG_BACKUP."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo crear el directorio de respaldo. Error: $($_.Exception.Message)"
            }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 6..." | Out-Null

        # 6. Respaldar archivos de configuración.
        Write-ColoredMessage -Type "info" "Paso 6: Respaldar archivos de configuración."
        Write-ColoredMessage -Type "warning" "Respaldando archivos de configuración en $CONFIG_BACKUP..."

        # --- CORRECCIÓN AQUÍ: Manejo más robusto de la salida de git checkout ---
        $gitCheckoutOutput = ""
        $gitExitCode = 0
        try {
            # Ejecutar git checkout y capturar la salida y el código de salida.
            # El 2>&1 redirige stderr a stdout, y Out-String lo captura como una sola cadena.
            # El bloque script { ... } permite que $ErrorActionPreference no detenga la ejecución aquí.
            $gitCheckoutResult = & {
                & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" checkout 2>&1
            }
            $gitCheckoutOutput = $gitCheckoutResult | Out-String
            $gitExitCode = $LASTEXITCODE # Captura el código de salida del último comando externo
        } catch {
            # Esto atraparía errores de PowerShell si el comando git no se encuentra, etc.
            Write-ColoredMessage -Type "error" "Error inesperado al ejecutar 'git checkout' para obtener la lista de archivos: $($_.Exception.Message)"
            exit 1
        }

        $backupFilesList = @()
        $inUntrackedSection = $false
        $isExpectedGitWarning = $false

        # Verificar si la salida contiene la advertencia esperada de Git
        if ($gitCheckoutOutput -match "error: The following untracked working tree files would be overwritten by checkout:") {
            $isExpectedGitWarning = $true
            # Procesar la salida para extraer los nombres de los archivos
            foreach ($line in ($gitCheckoutOutput -split "`n")) {
                if ($line -match "error: The following untracked working tree files would be overwritten by checkout:") {
                    $inUntrackedSection = $true
                    continue
                }
                if ($inUntrackedSection -and $line -match "^\s+\./(.+)$") {
                    $backupFilesList += $Matches[1].Trim()
                } elseif ($inUntrackedSection -and $line.Trim() -eq "") {
                    break
                }
            }
        }
        
        # Si Git salió con un código de error Y NO es la advertencia esperada, entonces es un error real.
        if ($gitExitCode -ne 0 -and -not $isExpectedGitWarning) {
            Write-ColoredMessage -Type "error" "Error inesperado de Git al obtener la lista de archivos: $($gitCheckoutOutput)"
        } elseif ($backupFilesList.Length -gt 0) {
            # Si hay archivos para respaldar (ya sea por la advertencia esperada o por otros motivos)
            Handle-BackupFiles -FilesToHandle $backupFilesList
        } else {
            Write-ColoredMessage -Type "info" "No hay archivos que respaldar o eliminar."
        }
        # --- FIN CORRECCIÓN ---

        # 7. Hacer checkout de la configuración.
        Write-ColoredMessage -Type "info" "Paso 7: Hacer checkout de la configuración."
        Write-ColoredMessage -Type "warning" "Haciendo checkout de la configuración..."
        try {
            Invoke-GitConfig checkout | Out-Null # Suprimimos la salida
            Write-ColoredMessage -Type "info" "Configuración aplicada exitosamente."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo hacer checkout de la configuración. Por favor, revisa si hay conflictos manualmente. Error: $($_.Exception.Message)"
        }

        Write-ColoredMessage -Type "info" "¡Configuración de HOME completada!"
    }
    "2" {
        Write-ColoredMessage -Type "info" "Ejecutando el proceso paso a paso. Por favor, siga las instrucciones:"

        # 1. Eliminar la configuración anterior (si existe).
        Write-ColoredMessage -Type "info" "Paso 1: Eliminar configuración anterior (si existe)."
        if (Test-Path $HOME_CFG -PathType Container) {
            Write-ColoredMessage -Type "warning" "Se ha encontrado una configuración anterior en $HOME_CFG."
            $respuesta = Read-Host -Prompt "¿Desea eliminarla? (s/n)"
            Write-Host "" # Nueva línea
            if ($respuesta.ToLower() -eq "s") {
                Write-ColoredMessage -Type "warning" "Eliminando configuración anterior en $HOME_CFG..."
                try {
                    Remove-Item -Path $HOME_CFG -Recurse -Force
                    Write-ColoredMessage -Type "info" "Configuración anterior eliminada."
                } catch {
                    Write-ColoredMessage -Type "error" "No se pudo eliminar la configuración anterior en $HOME_CFG. Error: $($_.Exception.Message)"
                }
            } else {
                Write-ColoredMessage -Type "warning" "La configuración anterior se mantendrá."
            }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 2..." | Out-Null

        # 2. Clonar o inicializar el repositorio bare.
        Write-ColoredMessage -Type "info" "Paso 2: Clonar o inicializar el repositorio bare."
        if (-not (Test-Path $HOME_CFG -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Clonando el repositorio bare en $HOME_CFG..."
            try {
                # Directamente usar git clone, sin Invoke-GitConfig
                & $GIT_BIN clone --bare --branch "windows" "https://github.com/Ebriopes/dotfiles.git" "$HOME_CFG"
                Write-ColoredMessage -Type "info" "Repositorio bare clonado exitosamente en $HOME_CFG."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo clonar el repositorio bare. Error: $($_.Exception.Message)"
            }
        } else {
             Write-ColoredMessage -Type "warning" "Inicializando un repositorio bare existente en $HOME_CFG..."
             try {
                 Write-ColoredMessage -Type "info" "El directorio $HOME_CFG ya existe. Asumiendo que es el repositorio bare."
             } catch {
                 Write-ColoredMessage -Type "error" "No se pudo inicializar el repositorio bare. Error: $($_.Exception.Message)"
             }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 3..." | Out-Null

        # 3. Crear un alias para el comando git (en PowerShell, es una función o alias de PowerShell)
        Write-ColoredMessage -Type "info" "Paso 3: Configurar alias para el comando git..."
        if (-not (Test-Path $SHELL_CONFIG_FILE)) {
            New-Item -Path $SHELL_CONFIG_FILE -ItemType File -Force | Out-Null
        }

        # Usar el nuevo nombre de la función
        $aliasContent = "function $($DOTFILES_GIT_FUNCTION_NAME) { & git --git-dir='$HOME_CFG/' --work-tree='$HOME' `$args }"
        # Usar Select-String con -Raw para buscar la línea completa y evitar problemas con caracteres especiales
        if (-not (Get-Content $SHELL_CONFIG_FILE -Raw | Select-String -Pattern "^function $($DOTFILES_GIT_FUNCTION_NAME) {" -Quiet)) {
            try {
                Add-Content -Path $SHELL_CONFIG_FILE -Value $aliasContent
                Write-ColoredMessage -Type "info" "Función '$($DOTFILES_GIT_FUNCTION_NAME)' agregada a $SHELL_CONFIG_FILE. Reinicia PowerShell para que tenga efecto."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo agregar la función '$($DOTFILES_GIT_FUNCTION_NAME)' a $SHELL_CONFIG_FILE. Error: $($_.Exception.Message)"
            }
        } else {
            Write-ColoredMessage -Type "warning" "La función '$($DOTFILES_GIT_FUNCTION_NAME)' ya existe en $SHELL_CONFIG_FILE. No se modificará."
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 4..." | Out-Null

        # 4. Desactivar el seguimiento de archivos no rastreados.
        Write-ColoredMessage -Type "info" "Paso 4: Desactivar el seguimiento de archivos no rastreados."
        Write-ColoredMessage -Type "warning" "Desactivando el seguimiento de archivos no rastreados..."
        try {
            & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" config status.showUntrackedFiles no
            Write-ColoredMessage -Type "info" "No tracking files."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo desactivar el seguimiento de archivos no rastreados. Error: $($_.Exception.Message)"
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 5..." | Out-Null

        # 5. Crear el directorio de respaldo (si no existe).
        Write-ColoredMessage -Type "info" "Paso 5: Crear el directorio de respaldo."
        if (-not (Test-Path $CONFIG_BACKUP -PathType Container)) {
            Write-ColoredMessage -Type "warning" "Creando directorio de respaldo en $CONFIG_BACKUP..."
            try {
                New-Item -ItemType Directory -Path $CONFIG_BACKUP -Force | Out-Null
                Write-ColoredMessage -Type "info" "Directorio de respaldo creado exitosamente en $CONFIG_BACKUP."
            } catch {
                Write-ColoredMessage -Type "error" "No se pudo crear el directorio de respaldo. Error: $($_.Exception.Message)"
            }
        }
        Read-Host -Prompt "Presione Enter para continuar con el Paso 6..." | Out-Null

        # 6. Respaldar archivos de configuración.
        Write-ColoredMessage -Type "info" "Paso 6: Respaldar archivos de configuración."
        Write-ColoredMessage -Type "warning" "Respaldando archivos de configuración en $CONFIG_BACKUP..."

        # --- CORRECCIÓN AQUÍ: Manejo más robusto de la salida de git checkout ---
        $gitCheckoutOutput = ""
        $gitExitCode = 0
        try {
            # Ejecutar git checkout y capturar la salida y el código de salida.
            # El 2>&1 redirige stderr a stdout, y Out-String lo captura como una sola cadena.
            # El bloque script { ... } permite que $ErrorActionPreference no detenga la ejecución aquí.
            $gitCheckoutResult = & {
                & $GIT_BIN --git-dir="$HOME_CFG/" --work-tree="$HOME" checkout 2>&1
            }
            $gitCheckoutOutput = $gitCheckoutResult | Out-String
            $gitExitCode = $LASTEXITCODE # Captura el código de salida del último comando externo
        } catch {
            # Esto atraparía errores de PowerShell si el comando git no se encuentra, etc.
            Write-ColoredMessage -Type "error" "Error inesperado al ejecutar 'git checkout' para obtener la lista de archivos: $($_.Exception.Message)"
            exit 1
        }

        $backupFilesList = @()
        $inUntrackedSection = $false
        $isExpectedGitWarning = $false

        # Verificar si la salida contiene la advertencia esperada de Git
        if ($gitCheckoutOutput -match "error: The following untracked working tree files would be overwritten by checkout:") {
            $isExpectedGitWarning = true
            # Procesar la salida para extraer los nombres de los archivos
            foreach ($line in ($gitCheckoutOutput -split "`n")) {
                if ($line -match "error: The following untracked working tree files would be overwritten by checkout:") {
                    $inUntrackedSection = $true
                    continue
                }
                if ($inUntrackedSection -and $line -match "^\s+\./(.+)$") {
                    $backupFilesList += $Matches[1].Trim()
                } elseif ($inUntrackedSection -and $line.Trim() -eq "") {
                    break
                }
            }
        }
        
        # Si Git salió con un código de error Y NO es la advertencia esperada, entonces es un error real.
        if ($gitExitCode -ne 0 -and -not $isExpectedGitWarning) {
            Write-ColoredMessage -Type "error" "Error inesperado de Git al obtener la lista de archivos: $($gitCheckoutOutput)"
        } elseif ($backupFilesList.Length -gt 0) {
            # Si hay archivos para respaldar (ya sea por la advertencia esperada o por otros motivos)
            Handle-BackupFiles -FilesToHandle $backupFilesList
        } else {
            Write-ColoredMessage -Type "info" "No hay archivos que respaldar o eliminar."
        }
        # --- FIN CORRECCIÓN ---

        # 7. Hacer checkout de la configuración.
        Write-ColoredMessage -Type "info" "Paso 7: Hacer checkout de la configuración."
        Write-ColoredMessage -Type "warning" "Haciendo checkout de la configuración..."
        try {
            Invoke-GitConfig checkout | Out-Null # Suprimimos la salida
            Write-ColoredMessage -Type "info" "Configuración aplicada exitosamente."
        } catch {
            Write-ColoredMessage -Type "error" "No se pudo hacer checkout de la configuración. Por favor, revisa si hay conflictos manualmente. Error: $($_.Exception.Message)"
        }

        Write-ColoredMessage -Type "info" "¡Configuración de HOME completada!"
    }
    "3" {
        Write-ColoredMessage -Type "info" "Saliendo del script."
        exit 0
    }
}

