#!/usr/bin/env bash
# Configura el HOME del usuario usando un repositorio Git bare.

set -euo pipefail

# Variables
HOME_CFG="$HOME/.cfg"
CONFIG_BACKUP="$HOME/.config-backup"
GIT_BIN="/usr/bin/git"
SHELL_CONFIG_FILE=""
DOTFILES_REPO="https://github.com/Ebriopes/dotfiles.git"

# Funciones
config() {
    "$GIT_BIN" --git-dir="$HOME_CFG/" --work-tree="$HOME" "$@"
}

msg() {
    local type="$1" message="$2"
    case "$type" in
        info) color="1;32m";;
        warning) color="1;33m";;
        error) color="1;31m"; exit 1;;
        *) color="0m";;
    esac
    printf "[${color}%s\n[0m" "$message"
}

show_menu() {
    printf "\n[1;33mMenú de Configuración de HOME[0m\n"
    printf "1. Ejecutar el proceso completo automáticamente\n"
    printf "2. Ejecutar paso a paso\n"
    printf "3. Salir\n"
    read -rp "Seleccione una opción: " -t 10 opcion
    printf "\n"

    [[ "$opcion" =~ ^[1-3]$ ]] || { msg error "Opción inválida o tiempo de espera excedido."; exit 1; }
    msg info "Opción seleccionada: $opcion"
}

backup_files() {
    local files="$1"
    [[ -z "$files" ]] && { msg info "No hay archivos que respaldar o eliminar."; return; }

    msg warning "Se encontraron archivos sin seguimiento que podrían ser sobrescritos."
    read -rp "¿Desea [r]espaldarlos, [e]liminarlos, o [a]abortar?: " -n 1 respuesta
    printf "\n"

    case "$respuesta" in
        [Rr])
            msg info "Respaldando archivos..."
            while IFS= read -r file; do
                msg warning "Respaldando $file en $CONFIG_BACKUP..."
                mkdir -p "$CONFIG_BACKUP"
                mv "$HOME/$file" "$CONFIG_BACKUP/$file" || { msg error "No se pudo respaldar $file"; return 1; }
                msg info "$file respaldado exitosamente en $CONFIG_BACKUP"
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
}

config_alias() {
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG_FILE="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG_FILE="$HOME/.zshrc"
    elif [ -f "$HOME/.config/fish/config.fish" ]; then
        SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish"
    else
        msg error "No se encontró un archivo de configuración de shell compatible."
    fi

    if ! grep -q "^alias config=" "$SHELL_CONFIG_FILE"; then
        printf "alias config='%s --git-dir=%s --work-tree=%s'\n" "$GIT_BIN" "$HOME_CFG" "$HOME" >>"$SHELL_CONFIG_FILE" || msg error "No se pudo agregar el alias 'config'."
        msg info "Alias 'config' agregado a $SHELL_CONFIG_FILE."
    else
        msg warning "El alias 'config' ya existe. No se modificará."
    fi
}

one_time_setup() {
    # 1. Clonar el repositorio bare.
    if [ -d "$HOME_CFG" ]; then
        msg info "La carpeta $HOME_CFG ya existe."
    else
        msg info "Clonando el repositorio bare en $HOME_CFG..."
        git clone --bare "$DOTFILES_REPO" "$HOME_CFG" || msg error "No se pudo clonar el repositorio bare."
        msg info "Repositorio bare clonado exitosamente en $HOME_CFG."
    fi

    # 2. Configurar alias.
    config_alias

    # 3. Desactivar el seguimiento de archivos no rastreados.
    msg info "Desactivando el seguimiento de archivos no rastreados..."
    config config status.showUntrackedFiles no || msg error "No se pudo desactivar el seguimiento de archivos no rastreados."
    msg info "No tracking files."

    # 4. Crear el directorio de respaldo.
    [ -d "$CONFIG_BACKUP" ] || { msg warning "Creando directorio de respaldo en $CONFIG_BACKUP..."; mkdir -p "$CONFIG_BACKUP" || msg error "No se pudo crear el directorio de respaldo."; msg info "Directorio de respaldo creado exitosamente."; }

    # 5. Respaldar archivos de configuración.
    msg warning "Respaldando archivos de configuración en $CONFIG_BACKUP..."
    backup_files_list=$(config checkout 2>&1 | awk '/untracked working tree files/{f=1; next} f && /^\s+\./{print $1}')
    backup_files "$backup_files_list" "r"

    # 6. Hacer checkout de la configuración.
    msg warning "Haciendo checkout de la configuración..."
    config checkout >/dev/null 2>&1
    [ "$?" -ne 0 ] && msg error "No se pudo hacer checkout de la configuración." || msg info "Configuración aplicada exitosamente."
}

step_by_step() {
    read -rp "Seleccione los pasos a ejecutar (separados por espacios, o 'todos'): " pasos
    IFS=' ' read -r -a pasos_array <<< "$pasos"

    ejecutar_paso() {
        [[ " ${pasos_array[*]} " =~ " $1 " ]] || [[ " ${pasos_array[*]} " =~ " todos " ]]
    }

    # 1. Clonar el repositorio bare.
    if ejecutar_paso 1; then
        if [ -d "$HOME_CFG" ]; then
            msg info "La carpeta $HOME_CFG ya existe."
        else
            msg info "Clonando el repositorio bare en $HOME_CFG..."
            git clone --bare "$DOTFILES_REPO" "$HOME_CFG" || msg error "No se pudo clonar el repositorio bare."
            msg info "Repositorio bare clonado exitosamente en $HOME_CFG."
        fi
    fi

    # 2. Configurar alias.
    if ejecutar_paso 2; then
        config_alias
    fi

    # 3. Desactivar el seguimiento de archivos no rastreados.
    if ejecutar_paso 3; then
        msg info "Desactivando el seguimiento de archivos no rastreados..."
        config config status.showUntrackedFiles no || msg error "No se pudo desactivar el seguimiento de archivos no rastreados."
        msg info "No tracking files."
    fi

    # 4. Crear el directorio de respaldo.
    if ejecutar_paso 4; then
        [ -d "$CONFIG_BACKUP" ] || { msg warning "Creando directorio de respaldo en $CONFIG_BACKUP..."; mkdir -p "$CONFIG_BACKUP" || msg error "No se pudo crear el directorio de respaldo."; msg info "Directorio de respaldo creado exitosamente."; }
    fi

    # 5. Respaldar archivos de configuración.
    if ejecutar_paso 5; then
        msg warning "Respaldando archivos de configuración en $CONFIG_BACKUP..."
        backup_files_list=$(config checkout 2>&1 | awk '/untracked working tree files/{f=1; next} f && /^\s+\./{print $1}')
        backup_files "$backup_files_list" "r"
    fi

    # 6. Hacer checkout de la configuración.
    if ejecutar_paso 6; then
        msg warning "Haciendo checkout de la configuración..."
        config checkout >/dev/null 2>&1
        [ "$?" -ne 0 ] && msg error "No se pudo hacer checkout de la configuración." || msg info "Configuración aplicada exitosamente."
    fi
}

# Main
msg info "Configurando tu HOME desde el repositorio Git bare..."
show_menu

case "$opcion" in
    1)
        msg info "Ejecutando el proceso completo automáticamente..."
        one_time_setup
    ;;
    2)
        msg info "Ejecutando el proceso paso a paso..."
        step_by_step
    ;;
    3)
        msg info "Saliendo del script."
        exit 0
    ;;
    *)
        msg error "Opción inválida."
        exit 1
    ;;
esac

msg info "¡Configuración de HOME completada!"
