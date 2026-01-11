# =============================================================================
# Script de Instalación de Dotfiles para Windows PowerShell
#
# Configura el directorio HOME del usuario para ser gestionado por un 
# repositorio Git bare, permitiendo el control de versiones de los archivos 
# de configuración ("dotfiles").
# =============================================================================

################################################################################
# TODO
# Crear enlaces a los archivos de la configuracion, 
# tales como los archivos Powershell $PROFILE
################################################################################

# --- Configuración del Script ---
# Detiene la ejecución del script inmediatamente si ocurre un error.
$ErrorActionPreference = 'Stop'
# Activa el modo estricto para detectar errores comunes.
Set-StrictMode -Version Latest

# Asegurar que la salida de Git esté en inglés para que el análisis de texto (regex) funcione correctamente.
$env:LC_ALL = 'C'

# --- Variables Globales ---
$DotfilesRepoUrl = "https://github.com/Ebriopes/dotfiles.git"
$DotfilesBranch = "windows"
$HomeBareRepoPath = Join-Path $HOME ".cfg"
$BackupPath = Join-Path $HOME ".config-backup"
$GitCommand = "git"
$GitAliasName = "dotfiles" # Alias más corto y común para esta técnica.

# --- Verificación de Prerrequisitos ---
if (-not (Get-Command $GitCommand -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Red "Error: Git no está instalado o no se encuentra en el PATH del sistema."
    exit 1
}

# --- Funciones Auxiliares ---

function Write-Styled {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Info", "Warning", "Error", "Success", "Section")]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $colorMap = @{
        "Info"    = "Cyan"
        "Warning" = "Yellow"
        "Error"   = "Red"
        "Success" = "Green"
        "Section" = "Magenta"
    }
    
    if ($Type -eq "Section") {
        Write-Host ""
        Write-Host -ForegroundColor $colorMap[$Type] "--- $Message ---"
    } else {
        Write-Host -ForegroundColor $colorMap[$Type] "[$Type] $Message"
    }

    if ($Type -eq "Error") {
        # Termina el script en caso de error gestionado.
        exit 1
    }
}

function Invoke-DotfilesGit {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    # Ejecuta cualquier comando Git apuntando al repositorio bare y al work-tree del HOME.
    & $GitCommand --git-dir="$HomeBareRepoPath" --work-tree="$HOME" @Arguments
}

# --- Lógica Principal de Instalación ---

function Get-CheckoutConflicts {
    Write-Styled -Type "Info" "Buscando conflictos de archivos (archivos existentes no rastreados)..."
    
    try {
        # Simulamos un checkout para que Git nos diga qué archivos serían sobrescritos.
        # Redirigimos el stream de error (2) al de éxito (1) para capturarlo todo.
        $checkoutOutput = Invoke-DotfilesGit checkout 2>&1
    } catch {
        # $checkoutOutput contendrá el mensaje de error de la excepción.
        $checkoutOutput = $_.Exception.Message
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Styled -Type "Success" "No se encontraron conflictos."
        return @() # Devuelve un array vacío si no hay conflictos.
    }
    
    $conflictingFiles = @()
    $isConflictError = $false

    # Procesamos la salida línea por línea.
    foreach ($line in ($checkoutOutput -split [System.Environment]::NewLine)) {
        if ($line -match "error: The following untracked working tree files would be overwritten by checkout:") {
            $isConflictError = $true
            continue
        }
        
        if ($isConflictError -and ($line -match "^\s+(.+)$")) {
            # Capturamos cada archivo que Git reporta.
            $conflictingFiles += $Matches[1].Trim()
        }
    }

    if (-not $isConflictError) {
        Write-Styled -Type "Error" "Ocurrió un error inesperado durante el `git checkout`. Detalles:`n$checkoutOutput` "
    }
    
    return $conflictingFiles
}

function Handle-ConflictingFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Files
    )

    Write-Styled -Type "Warning" "Se encontraron los siguientes archivos que entrarían en conflicto:"
    $Files | ForEach-Object { Write-Host "  - $_" }
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]@(
        "&Respaldar (Mover a $BackupPath)",
        "&Eliminar (Borrarlos permanentemente)",
        "&Abortar instalación"
    )
    $choice = $Host.UI.PromptForChoice("Acción requerida", "¿Qué deseas hacer con estos archivos?", $options, 2)

    switch ($choice) {
        0 { # Respaldar
            Write-Styled -Type "Info" "Respaldando archivos en '$BackupPath'..."
            if (-not (Test-Path $BackupPath)) {
                New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            }
            foreach ($file in $Files) {
                $source = Join-Path $HOME $file
                # Para preservar la estructura de directorios en el backup.
                $destination = Join-Path $BackupPath $file
                
                $destDir = Split-Path $destination -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }
                
                Write-Host "Moviendo '$source' a '$destination'..."
                Move-Item -Path $source -Destination $destination -Force
            }
            Write-Styled -Type "Success" "Todos los archivos en conflicto han sido respaldados."
        }
        1 { # Eliminar
            Write-Styled -Type "Warning" "Eliminando archivos en conflicto..."
            foreach ($file in $Files) {
                $target = Join-Path $HOME $file
                Write-Host "Eliminando '$target'..."
                Remove-Item -Path $target -Recurse -Force
            }
            Write-Styled -Type "Success" "Todos los archivos en conflicto han sido eliminados."
        }
        2 { # Abortar
            Write-Styled -Type "Error" "Instalación abortada por el usuario."
        }
    }
}

function Start-DotfilesInstallation {
    param(
        [switch]$StepByStep
    )
    
    $PauseAction = {
        if ($StepByStep) {
            Read-Host "Presiona Enter para continuar con el siguiente paso..." | Out-Null
        }
    }

    # -- PASO 1: Clonar Repositorio --
    Write-Styled -Type "Section" "Paso 1: Clonar Repositorio Bare"
    if (Test-Path $HomeBareRepoPath) {
        Write-Styled -Type "Warning" "El directorio '$HomeBareRepoPath' ya existe. Se asumirá que es el repositorio correcto."
    } else {
        Write-Styled -Type "Info" "Clonando '$DotfilesRepoUrl' en '$HomeBareRepoPath'..."
        try {
            & $GitCommand clone --bare --branch "$DotfilesBranch" "$DotfilesRepoUrl" "$HomeBareRepoPath"
            Write-Styled -Type "Success" "Repositorio clonado exitosamente."
        } catch {
            Write-Styled -Type "Error" "No se pudo clonar el repositorio. Error: $($_.Exception.Message)"
        }
    }
    & $PauseAction
    
    # -- PASO 2: Crear Alias en el Perfil de PowerShell --
    Write-Styled -Type "Section" "Paso 2: Configurar alias '$GitAliasName'"
    $profilePath = $PROFILE
    
    # Asegurar que el directorio del perfil exista antes de intentar crear el archivo
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    if (-not (Test-Path $profilePath)) {
        Write-Styled -Type "Info" "Creando archivo de perfil en '$profilePath'..."
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
    }
    
    $aliasFunction = "function $($GitAliasName) { & git --git-dir='$HomeBareRepoPath' --work-tree='$HOME' `$args }"
    if (Select-String -Path $profilePath -Pattern $GitAliasName -Quiet) {
        Write-Styled -Type "Warning" "La función/alias '$GitAliasName' ya parece existir en tu perfil. No se realizarán cambios."
    } else {
        Write-Styled -Type "Info" "Añadiendo función '$GitAliasName' a tu perfil de PowerShell."
        Add-Content -Path $profilePath -Value "`n# Alias para gestionar dotfiles`n$aliasFunction"
        Write-Styled -Type "Success" "Alias añadido. Deberás reiniciar tu terminal para usarlo."
    }
    & $PauseAction

    # -- PASO 3: Configurar Repositorio Local --
    Write-Styled -Type "Section" "Paso 3: Configurar Repositorio Local"
    Write-Styled -Type "Info" "Configurando 'status.showUntrackedFiles' en 'no' para ocultar archivos no rastreados."
    try {
        Invoke-DotfilesGit config status.showUntrackedFiles no
        Write-Styled -Type "Success" "Configuración aplicada."
    } catch {
        Write-Styled -Type "Error" "No se pudo aplicar la configuración de Git. Error: $($_.Exception.Message)"
    }
    & $PauseAction

    # -- PASO 4: Respaldar Archivos en Conflicto --
    Write-Styled -Type "Section" "Paso 4: Verificar y Resolver Conflictos"
    $conflictingFiles = @(Get-CheckoutConflicts)
    if ($conflictingFiles.Count -gt 0) {
        Handle-ConflictingFiles -Files $conflictingFiles
    }
    & $PauseAction
    
    # -- PASO 5: Aplicar los Dotfiles --
    Write-Styled -Type "Section" "Paso 5: Aplicar los Dotfiles (Checkout)"
    Write-Styled -Type "Info" "Realizando el checkout de los archivos en tu directorio HOME..."
    try {
        Invoke-DotfilesGit checkout
        Write-Styled -Type "Success" "¡Checkout completado! Tus dotfiles están en su sitio."
    } catch {
        Write-Styled -Type "Error" "Falló el checkout final. Puede que aún haya conflictos. Error: $($_.Exception.Message)"
    }

    # -- FINALIZACIÓN --
    Write-Styled -Type "Section" "Instalación Finalizada"
    Write-Styled -Type "Success" "El proceso ha terminado. Por favor, reinicia tu terminal para que el alias '$GitAliasName' esté disponible."
    Write-Styled -Type "Info" "Puedes gestionar tus dotfiles con comandos como: '$GitAliasName status', '$GitAliasName add .', etc."
}


# --- Menú Principal ---
$menuOptions = [System.Management.Automation.Host.ChoiceDescription[]]@(
    "&Instalación automática",
    "Instalación &paso a paso",
    "&Salir"
)
$choice = $Host.UI.PromptForChoice("Instalador de Dotfiles", "Bienvenido. ¿Cómo quieres proceder?", $menuOptions, 2)

switch ($choice) {
    0 { Start-DotfilesInstallation }
    1 { Start-DotfilesInstallation -StepByStep }
    2 { Write-Styled -Type "Info" "Operacion cancelada. No se han realizado cambios."; exit 0 }
}