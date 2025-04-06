#!/usr/bin/env bash
# Configura el HOME del usuario usando un repositorio Git bare.

set -euo pipefail # Hace que el script termine si un comando falla.

# Variables para rutas y comandos.
HOME_CFG="$HOME/.cfg"
CONFIG_BACKUP="$HOME/.config-backup"
GIT_BIN="/usr/bin/git"
SHELL_CONFIG_FILE=""

# Función para ejecutar comandos de git en el repositorio bare.
config() {
    "$GIT_BIN" --git-dir="$HOME_CFG/" --work-tree="$HOME" "$@"
}

# Función para imprimir mensajes con color.
msg() {
    local type="$1"
    local message="$2"
    case "$type" in
        info)
            printf "[1;32m%s\n[0m" "$message"
        ;;
        warning)
            printf "[1;33m%s\n[0m" "$message"
        ;;
        error)
            printf "[1;31m%s\n[0m" "$message"
            exit 1
        ;;
        *)
            printf "%s\n" "$message"
        ;;
    esac
}

opcion=""
# Función para mostrar el menú y obtener la opción seleccionada.
show_menu() {
    printf "\n[1;33mMenú de Configuración de HOME[0m\n"
    printf "1. Ejecutar el proceso completo automáticamente\n"
    printf "2. Ejecutar paso a paso\n"
    printf "3. Salir\n"
    read -rp "Seleccione una opción: " -t 10 opcion
    printf "\n"
    
    # Verificar si la lectura fue exitosa y si la opción está dentro del rango
    if [ -n "$opcion" ] && [[ "$opcion" -ge 1 && "$opcion" -le 3 ]]; then
        echo "Opción seleccionada: $opcion" # Mensaje de debug
        # echo "$opcion" # No es necesario imprimir la opción dos veces
        return 0 # Devolver 0 para indicar éxito
    else
        msg error "Opción inválida o tiempo de espera excedido. Saliendo del script."
        exit 1
    fi
}

# Función para respaldar archivos.
backup_files() {
    local files="$1"
    local action="$2" # 'r' para respaldar, 'e' para eliminar, 'a' para abortar
    
    if [ -n "$files" ]; then
        msg warning "Se encontraron archivos sin seguimiento que podrían ser sobrescritos."
        read -p "¿Desea [r]espaldarlos, [e]liminarlos, o [a]abortar?: " -n 1 respuesta
        printf "\n"
        case "$respuesta" in
            [Rr])
                msg info "Respaldando archivos..."
                while IFS= read -r file; do
                    msg warning "Respaldando $file en $CONFIG_BACKUP..."
                    if mv "$HOME/$file" "$CONFIG_BACKUP/$file"; then
                        msg info "$file respaldado exitosamente en $CONFIG_BACKUP"
                    else
                        msg error "No se pudo respaldar $file"
                        return 1 # Detener el proceso si falla el respaldo
                    fi
                done < <(printf "%s\n" "$files")
            ;;
            [Ee])
                msg warning "Eliminando archivos sin seguimiento..."
                while IFS= read -r file; do
                    msg warning "Eliminando $file..."
                    rm -rf "$HOME/$file" || msg error "No se pudo eliminar $file"
                done < <(printf "%s\n" "$files")
                msg info "Archivos eliminados."
            ;;
            [Aa])
                msg error "Operación abortada por el usuario."
                exit 1
            ;;
            *)
                msg error "Opción inválida. Abortando."
                exit 1
            ;;
        esac
    else
        msg info "No hay archivos que respaldar o eliminar."
    fi
}

# Inicio del script
msg info "Configurando tu HOME desde el repositorio Git bare..."

# Mostrar el menú y obtener la opción del usuario.
show_menu # Llamar a la función show_menu

# Ejecutar la opción seleccionada.
case "$opcion" in # Este case está duplicado, pero lo dejo para mantener la lógica original
    1)
        msg info "Ejecutando el proceso completo automáticamente..."
        # 1. Verificar si la carpeta .cfg ya existe.
        if [ -d "$HOME_CFG" ]; then
            msg info "La carpeta $HOME_CFG ya existe. Saltando el paso de clonar el repositorio."
        else
            msg info "Clonando el repositorio bare directamente en $HOME_CFG..."
            git clone --bare https://github.com/Ebriopes/dotfiles.git "$HOME_CFG" || msg error "No se pudo clonar el repositorio bare en $HOME_CFG."
            msg info "Repositorio bare clonado exitosamente en $HOME_CFG."
        fi

        # 2. Crear un alias para el comando git
        msg info "Paso 2: Configurar alias para el comando git..."
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG_FILE="$HOME/.bashrc"
            elif [ -f "$HOME/.zshrc" ]; then
            SHELL_CONFIG_FILE="$HOME/.zshrc"
            elif [ -f "$HOME/.config/fish/config.fish" ]; then
            SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish"
        else
            msg error "No se encontró un archivo de configuración de shell compatible (.bashrc, .zshrc, .config/fish/config.fish)."
        fi
        
        # Agregar el alias al archivo de configuración del shell si no existe.
        if ! grep -q "^alias config=" "$SHELL_CONFIG_FILE"; then
            printf "alias config='%s --git-dir=%s --work-tree=%s'\n" "$GIT_BIN" "$HOME_CFG" "$HOME" >>"$SHELL_CONFIG_FILE" || msg error "No se pudo agregar el alias 'config' a $SHELL_CONFIG_FILE."
            msg info "Alias 'config' agregado a $SHELL_CONFIG_FILE."
        else
            msg warning "El alias 'config' ya existe en $SHELL_CONFIG_FILE. No se modificará."
        fi
        
        # 3. Desactivar el seguimiento de archivos no rastreados.
        msg info "Paso 3: Desactivar el seguimiento de archivos no rastreados."
        printf "[1;33mDesactivando el seguimiento de archivos no rastreados...\n[0m"
        config config status.showUntrackedFiles no
        if [ $? -ne 0 ]; then
            printf "[1;31mError: No se pudo desactivar el seguimiento de archivos no rastreados.\n[0m"
            exit 1
        fi
        printf "[1;32mNo tracking files.\n[0m"
        
        # 4. Crear el directorio de respaldo (si no existe).
        msg info "Paso 4: Crear el directorio de respaldo."
        if [ ! -d "$CONFIG_BACKUP" ]; then
            msg warning "Creando directorio de respaldo en $CONFIG_BACKUP..."
            mkdir -p "$CONFIG_BACKUP" || msg error "No se pudo crear el directorio de respaldo."
            msg info "Directorio de respaldo creado exitosamente en $CONFIG_BACKUP."
        fi
        
        # 5. Respaldar el directorio ~/.config y otras rutas si existen.
        msg info "Paso 5: Respaldar archivos de configuración."
        msg warning "Respaldando archivos de configuración en $CONFIG_BACKUP..."
        # Obtener la lista de archivos a respaldar desde la salida de git checkout
        backup_files_list=$(config checkout 2>&1 | awk '/error: The following untracked working tree files would be overwritten by checkout:/{flag=1; next} flag && /^\s+\./{print $1}')
        backup_files "$backup_files_list" "r" #respaldar
        
        # 6. Hacer checkout de la configuración.
        msg info "Paso 6: Hacer checkout de la configuración."
        msg warning "Haciendo checkout de la configuración..."
        config checkout >/dev/null 2>&1 # Suprimimos la salida del comando checkout.
        CHECKOUT_RESULT=$?
        
        if [ $CHECKOUT_RESULT -ne 0 ]; then
            msg error "No se pudo hacer checkout de la configuración. Por favor, revisa si hay conflictos manualmente."
        else
            msg info "Configuración aplicada exitosamente."
        fi
        
        msg info "¡Configuración de HOME completada!"
    ;;
    2)
        msg info "Ejecutando el proceso paso a paso. Por favor, elija qué pasos ejecutar:"
        
        # Menú de selección de pasos
        printf "\n[1;33mSeleccione los pasos a ejecutar (separados por espacios, o 'todos'):[0m\n"
        printf "1. Eliminar configuración anterior\n"
        printf "2. Clonar o inicializar el repositorio bare\n"
        printf "3. Configurar alias para el comando git\n"
        printf "4. Desactivar el seguimiento de archivos no rastreados\n"
        printf "5. Crear el directorio de respaldo\n"
        printf "6. Respaldar archivos de configuración\n"
        printf "7. Hacer checkout de la configuración\n"
        read -rp "Pasos a ejecutar: " pasos
        printf "\n"
        
        # Convertir la entrada a un array
        IFS=' ' read -r -a pasos_array <<< "$pasos"
        
        # Función para verificar si un paso está en la lista de pasos a ejecutar
        function ejecutar_paso {
            local paso="$1"
            local -n array="$2"
            
            if [[ " ${array[*]} " =~ " ${paso} " ]] || [[ " ${array[*]} " =~ " todos " ]]; then
                return 0 # El paso debe ser ejecutado
            else
                return 1 # El paso no debe ser ejecutado
            fi
        }
        
        # 1. Verificar si la carpeta .cfg ya existe.
        if ejecutar_paso 1 pasos_array; then
            if [ -d "$HOME_CFG" ]; then
                msg info "La carpeta $HOME_CFG ya existe. Saltando el paso de clonar el repositorio."
            else
                msg info "Clonando el repositorio bare directamente en $HOME_CFG..."
                git clone --bare https://github.com/Ebriopes/dotfiles.git "$HOME_CFG" || msg error "No se pudo clonar el repositorio bare en $HOME_CFG."
                msg info "Repositorio bare clonado exitosamente en $HOME_CFG."
            fi
        fi
        
        # 2. Mover el repositorio temporal al destino final.
        if ejecutar_paso 2 pasos_array; then
            msg info "Paso 2: Mover el repositorio al destino final."
            if [ -d "$HOME_CFG" ]; then
            msg warning "Se ha encontrado una configuración anterior en $HOME_CFG."
            read -p "¿Desea sobrescribirla? (s/n): " -n 1 respuesta
            printf "\n"
            if [[ "$respuesta" =~ ^[Ss]$ ]]; then
                msg warning "Sobrescribiendo la configuración anterior en $HOME_CFG..."
                rm -rf "$HOME_CFG" || msg error "No se pudo eliminar la configuración anterior en $HOME_CFG."
                mv "$TEMP_DIR" "$HOME_CFG" || msg error "No se pudo mover el repositorio al destino final."
                msg info "Configuración sobrescrita exitosamente."
            else
                msg warning "La configuración anterior se mantendrá. Eliminando el directorio temporal."
                rm -rf "$TEMP_DIR" || msg error "No se pudo eliminar el directorio temporal."
            fi
            else
            mv "$TEMP_DIR" "$HOME_CFG" || msg error "No se pudo mover el repositorio al destino final."
            msg info "Repositorio movido exitosamente a $HOME_CFG."
            fi
        fi
        
        # 3. Crear un alias para el comando git
        if ejecutar_paso 3 pasos_array; then
            msg info "Paso 3: Configurar alias para el comando git..."
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_CONFIG_FILE="$HOME/.bashrc"
                elif [ -f "$HOME/.zshrc" ]; then
                SHELL_CONFIG_FILE="$HOME/.zshrc"
                elif [ -f "$HOME/.config/fish/config.fish" ]; then
                SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish"
            else
                msg error "No se encontró un archivo de configuración de shell compatible (.bashrc, .zshrc, .config/fish/config.fish)."
            fi
            
            # Agregar el alias al archivo de configuración del shell si no existe.
            if ! grep -q "^alias config=" "$SHELL_CONFIG_FILE"; then
                printf "alias config='%s --git-dir=%s --work-tree=%s'\n" "$GIT_BIN" "$HOME_CFG" "$HOME" >>"$SHELL_CONFIG_FILE" || msg error "No se pudo agregar el alias 'config' a $SHELL_CONFIG_FILE."
                msg info "Alias 'config' agregado a $SHELL_CONFIG_FILE."
            else
                msg warning "El alias 'config' ya existe en $SHELL_CONFIG_FILE. No se modificará."
            fi
        fi
        
        # 4. Desactivar el seguimiento de archivos no rastreados.
        if ejecutar_paso 4 pasos_array; then
            msg info "Paso 4: Desactivar el seguimiento de archivos no rastreados."
            printf "[1;33mDesactivando el seguimiento de archivos no rastreados...\n[0m"
            config config status.showUntrackedFiles no
            if [ $? -ne 0 ]; then
                printf "[1;31mError: No se pudo desactivar el seguimiento de archivos no rastreados.\n[0m"
                exit 1
            fi
            printf "[1;32mNo tracking files.\n[0m"
        fi
        
        # 5. Crear el directorio de respaldo (si no existe).
        if ejecutar_paso 5 pasos_array; then
            msg info "Paso 5: Crear el directorio de respaldo."
            if [ ! -d "$CONFIG_BACKUP" ]; then
                msg warning "Creando directorio de respaldo en $CONFIG_BACKUP..."
                mkdir -p "$CONFIG_BACKUP" || msg error "No se pudo crear el directorio de respaldo."
                msg info "Directorio de respaldo creado exitosamente en $CONFIG_BACKUP."
            fi
        fi
        
        # 6. Respaldar el directorio ~/.config y otras rutas si existen.
        if ejecutar_paso 6 pasos_array; then
            msg info "Paso 6: Respaldar archivos de configuración."
            msg warning "Respaldando archivos de configuración en $CONFIG_BACKUP..."
            # Obtener la lista de archivos a respaldar desde la salida de git checkout
            backup_files_list=$(config checkout 2>&1 | awk '/error: The following untracked working tree files would be overwritten by checkout:/{flag=1; next} flag && /^\s+\./{print $1}')
            backup_files "$backup_files_list" "r" #respaldar
        fi
        
        # 7. Hacer checkout de la configuración.
        if ejecutar_paso 7 pasos_array; then
            msg info "Paso 7: Hacer checkout de la configuración."
            msg warning "Haciendo checkout de la configuración..."
            config checkout >/dev/null 2>&1 # Suprimimos la salida del comando checkout.
            CHECKOUT_RESULT=$?
            
            if [ $CHECKOUT_RESULT -ne 0 ]; then
                msg error "No se pudo hacer checkout de la configuración. Por favor, revisa si hay conflictos manualmente."
            else
                msg info "Configuración aplicada exitosamente."
            fi
        fi
        
        msg info "¡Configuración de HOME completada!"
    ;;
    3)
        msg info "Saliendo del script."
        exit 0
    ;;
    *)
        msg error "Opción inválida. Saliendo del script."
        exit 1
    ;;
esac
