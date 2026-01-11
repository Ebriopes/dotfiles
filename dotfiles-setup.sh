#!/usr/bin/env bash

# =============================================================================
# Script de Instalación de Dotfiles Mejorado (Linux & macOS)
#
# Configura el HOME del usuario usando un repositorio Git bare con
# interactividad completa y manejo de errores.
# =============================================================================

# -- Configuración de seguridad --
set -uo pipefail

# Asegurar salida de Git en inglés para parsing
export LC_ALL=C

# --- Colores ANSI ---
COLOR_INFO="\033[0;36m"    # Cyan
COLOR_WARN="\033[0;33m"    # Yellow
COLOR_ERR="\033[0;31m"     # Red
COLOR_SUCCESS="\033[0;32m" # Green
COLOR_SECT="\033[0;35m"    # Magenta
COLOR_RESET="\033[0m"      # Reset

# --- Funciones de Utilidad ---

# Los logs van a stderr para no contaminar capturas de datos
write_styled() {
    local type="$1"
    local message="$2"
    local color="$COLOR_RESET"

    case "$type" in
        "Info")    color="$COLOR_INFO" ;;
        "Warning") color="$COLOR_WARN" ;;
        "Error")   color="$COLOR_ERR" ;;
        "Success") color="$COLOR_SUCCESS" ;;
        "Section") color="$COLOR_SECT" ;;
    esac

    if [ "$type" == "Section" ]; then
        echo -e "\n${color}=== $message ===${COLOR_RESET}" >&2
    else
        echo -e "${color}[$type] $message${COLOR_RESET}" >&2
    fi
}

# Ejecuta un comando y permite reintentar si falla
run_interactive_step() {
    local cmd=("$@")
    while true; do
        if "${cmd[@]}"; then
            return 0
        else
            write_styled "Warning" "El último paso ha fallado."
            echo "Opciones: [r]eintentar, [o]mitir, [a]bortar" >&2
            read -p "> " choice
            case "$choice" in
                [rR]*) continue ;;
                [oO]*) return 1 ;;
                [aA]*) write_styled "Error" "Instalación cancelada por el usuario."; exit 1 ;;
                *) echo "Opción no válida." >&2 ;;
            esac
        fi
    done
}

# --- Lógica de Git Bare ---

invoke_dotfiles_git() {
    git --git-dir="$HOME_BARE_REPO_PATH" --work-tree="$HOME" "$@"
}

get_checkout_conflicts() {
    # Intenta checkout de forma silenciosa
    if invoke_dotfiles_git checkout &> /dev/null; then
        return 0
    fi

    local output
    output=$(invoke_dotfiles_git checkout 2>&1 || true)
    local is_conflict_block=false

    while IFS= read -r line; do
        if [[ "$line" == *"error: The following untracked working tree files would be overwritten by checkout:"* ]]; then
            is_conflict_block=true
            continue
        fi
        if [[ "$line" == *"Please move or remove them"* ]]; then
            is_conflict_block=false
            continue
        fi

        if [ "$is_conflict_block" = true ]; then
            local file=$(echo "$line" | sed -e 's/^[[:space:]]*//')
            # Seguridad: Ignorar líneas vacías o referencias al propio HOME
            if [[ -n "$file" && "$file" != "." && "$file" != "./" ]]; then
                echo "$file"
            fi
        fi
    done <<< "$output"
}

handle_conflicting_files() {
    local files=("$@")
    write_styled "Warning" "Se detectaron archivos existentes que entrarían en conflicto:"
    for f in "${files[@]}"; do
        echo "  - $f" >&2
    done
    echo "" >&2

    echo "¿Qué deseas hacer con estos archivos?" >&2
    echo "1) Respaldar (Mover a $BACKUP_PATH)" >&2
    echo "2) Eliminar (¡Permanente!)" >&2
    echo "3) Abortar instalación" >&2
    read -p "Opción [1-3]: " choice

    case "$choice" in
        1)
            write_styled "Info" "Respaldando archivos..."
            mkdir -p "$BACKUP_PATH"
            for file in "${files[@]}"; do
                [[ -z "$file" || "$file" == "." ]] && continue
                local source="$HOME/$file"
                local destination="$BACKUP_PATH/$file"
                mkdir -p "$(dirname "$destination")"
                mv -f "$source" "$destination" 2>/dev/null || write_styled "Warning" "No se pudo mover $file"
            done
            write_styled "Success" "Respaldo completado."
            ;;
        2)
            write_styled "Warning" "Eliminando archivos..."
            for file in "${files[@]}"; do
                [[ -z "$file" || "$file" == "." ]] && continue
                rm -rf "$HOME/$file"
            done
            write_styled "Success" "Archivos eliminados."
            ;;
        *)
            write_styled "Error" "Instalación abortada." ;;
    esac
}

# --- Proceso de Instalación ---

start_installation() {
    local step_by_step=$1
    
    # --- Configuración Inicial ---
    write_styled "Section" "Configuración de Origen"
    
    OS_TYPE=$(uname -s)
    DETECTED_BRANCH="main"
    [[ "$OS_TYPE" == "Linux" ]] && DETECTED_BRANCH="linux"
    [[ "$OS_TYPE" == "Darwin" ]] && DETECTED_BRANCH="macos"

    read -p "URL del repositorio [$DOTFILES_REPO_URL]: " input_url
    DOTFILES_REPO_URL=${input_url:-$DOTFILES_REPO_URL}

    read -p "Rama a utilizar [$DETECTED_BRANCH]: " input_branch
    DOTFILES_BRANCH=${input_branch:-$DETECTED_BRANCH}

    # -- PASO 1: Clonar --
    write_styled "Section" "Paso 1: Clonar Repositorio Bare"
    if [ -d "$HOME_BARE_REPO_PATH" ]; then
        write_styled "Warning" "El directorio '$HOME_BARE_REPO_PATH' ya existe."
        read -p "¿Deseas borrarlo y volver a clonar? (s/N): " clean_choice
        if [[ "$clean_choice" =~ ^[sS]$ ]]; then
            rm -rf "$HOME_BARE_REPO_PATH"
        fi
    fi

    if [ ! -d "$HOME_BARE_REPO_PATH" ]; then
        run_interactive_step git clone --bare --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO_URL" "$HOME_BARE_REPO_PATH"
    fi

    # -- PASO 2: Alias --
    write_styled "Section" "Paso 2: Configurar Alias"
    local shell_config="$HOME/.bashrc"
    [[ "$SHELL" == *"zsh"* ]] && shell_config="$HOME/.zshrc"

    if grep -q "alias $GIT_ALIAS_NAME=" "$shell_config"; then
        write_styled "Info" "El alias ya existe en $shell_config."
    else
        echo -e "\nalias $GIT_ALIAS_NAME='git --git-dir=$HOME_BARE_REPO_PATH --work-tree=$HOME'" >> "$shell_config"
        write_styled "Success" "Alias añadido a $shell_config."
    fi

    # -- PASO 3: Configurar --
    write_styled "Section" "Paso 3: Configuración Local de Git"
    invoke_dotfiles_git config --local status.showUntrackedFiles no
    write_styled "Success" "Filtro de archivos no rastreados activado."

    # -- PASO 4: Conflictos --
    write_styled "Section" "Paso 4: Resolución de Conflictos"
    mapfile -t conflicts < <(get_checkout_conflicts)
    
    # Filtrar elementos vacíos
    local clean_conflicts=()
    for c in "${conflicts[@]}"; do [[ -n "$c" ]] && clean_conflicts+=("$c"); done

    if [ ${#clean_conflicts[@]} -gt 0 ]; then
        handle_conflicting_files "${clean_conflicts[@]}"
    else
        write_styled "Success" "No hay conflictos detectados."
    fi

    # -- PASO 5: Checkout --
    write_styled "Section" "Paso 5: Aplicar Archivos (Checkout)"
    if run_interactive_step invoke_dotfiles_git checkout; then
        write_styled "Success" "¡Dotfiles instalados correctamente!"
    fi

    write_styled "Section" "Proceso Finalizado"
    echo "Reinicia tu terminal o ejecuta: source $shell_config"
}

# --- Punto de Entrada ---

# Variables por defecto
DOTFILES_REPO_URL="https://github.com/Ebriopes/dotfiles.git"
HOME_BARE_REPO_PATH="$HOME/.cfg"
BACKUP_PATH="$HOME/.config-backup"
GIT_ALIAS_NAME="dotfiles"

if ! command -v git &> /dev/null; then
    write_styled "Error" "Git no está instalado. Instálalo antes de continuar."
fi

clear
echo -e "${COLOR_SECT}=== Instalador de Dotfiles Interactivo ===${COLOR_RESET}"
echo "1) Instalación automática"
echo "2) Instalación paso a paso"
echo "3) Salir"
read -p "Selección: " opt

case "$opt" in
    1) start_installation false ;;
    2) start_installation true ;;
    3) exit 0 ;;
    *) echo "Opción no válida."; exit 1 ;;
esac