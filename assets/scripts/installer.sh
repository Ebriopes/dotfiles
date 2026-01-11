#!/usr/bin/env bash

# =============================================================================
# Script de Instalación de Dotfiles para Linux y macOS
#
# Mejora del script original para permitir una instalación modular y selectiva
# de dependencias, basado en el gestor de paquetes del sistema operativo.
# =============================================================================

# --- Configuración del Script ---
# Detiene la ejecución del script inmediatamente si un comando falla.
set -eo pipefail

# --- Variables Globales y Detección del Entorno ---
OS=""
DISTRO=""
PACKAGE_MANAGER=""
NEEDS_SUDO="sudo"

# Función para dar formato a la salida en la terminal.
write_styled() {
    local type="$1"
    local message="$2"
    local color_info='\033[0;36m'    # Cyan
    local color_warning='\033[0;33m' # Yellow
    local color_error='\033[0;31m'   # Red
    local color_success='\033[0;32m' # Green
    local color_section='\033[0;35m' # Magenta
    local color_reset='\033[0m'

    case "$type" in
        "Info")
            printf "${color_info}[Info] %s${color_reset}\n" "$message"
            ;;
        "Warning")
            printf "${color_warning}[Warning] %s${color_reset}\n" "$message"
            ;;
        "Error")
            printf "${color_error}[Error] %s${color_reset}\n" "$message"
            exit 1
            ;;
        "Success")
            printf "${color_success}[Success] %s${color_reset}\n" "$message"
            ;;
        "Section")
            printf "\n${color_section}--- %s ---${color_reset}\n" "$message"
            ;;
    esac
}

detect_os() {
    write_styled "Info" "Detectando sistema operativo y gestor de paquetes..."
    OS=$(uname -s)

    if [[ "$OS" == "Linux" ]]; then
        if [ -r /etc/os-release ]; then
            # shellcheck source=/dev/null
            . /etc/os-release
            DISTRO=$ID
        else
            DISTRO="unknown"
        fi

        case "$DISTRO" in
            ubuntu|debian|pop) PACKAGE_MANAGER="apt-get" ;; 
            manjaro|arch) PACKAGE_MANAGER="pacman" ;; 
            alpine) PACKAGE_MANAGER="apk" ;; 
            fedora) PACKAGE_MANAGER="dnf" ;; 
            *) write_styled "Error" "Distribución de Linux no soportada: $DISTRO" 
        esac

    elif [[ "$OS" == "Darwin" ]]; then # macOS
        DISTRO="macOS"
        if command -v brew &>/dev/null; then
            PACKAGE_MANAGER="brew"
            NEEDS_SUDO="" # Homebrew no necesita sudo
        else
            write_styled "Error" "Homebrew no está instalado. Por favor, instálalo para continuar."
        fi
    else
        write_styled "Error" "Sistema operativo no soportado: $OS"
    fi
    write_styled "Success" "Sistema detectado: $OS ($DISTRO) con $PACKAGE_MANAGER."
}

# --- Funciones de Instalación ---

install_packages() {
    local packages_to_install=("$@")
    if [ ${#packages_to_install[@]} -eq 0 ]; then
        write_styled "Warning" "No se especificaron paquetes para instalar."
        return
    fi
    
    write_styled "Info" "Instalando los siguientes paquetes: ${packages_to_install[*]}"

    case "$PACKAGE_MANAGER" in
        "apt-get")
            $NEEDS_SUDO apt-get update
            $NEEDS_SUDO apt-get install -y "${packages_to_install[@]}"
            ;;
        "pacman")
            $NEEDS_SUDO pacman -Sy --noconfirm "${packages_to_install[@]}"
            ;;
        "apk")
            $NEEDS_SUDO apk add --no-cache "${packages_to_install[@]}"
            ;;
        "dnf")
            $NEEDS_SUDO dnf install -y "${packages_to_install[@]}"
            ;;
        "brew")
            $NEEDS_SUDO brew install "${packages_to_install[@]}"
            ;;
        *)
            write_styled "Error" "Gestor de paquetes no soportado: $PACKAGE_MANAGER"
            ;;
    esac
    write_styled "Success" "Paquetes instalados correctamente."
}

install_base_deps() {
    write_styled "Section" "Instalando Dependencias Base"
    local packages=("git" "curl" "wget" "stow")
    install_packages "${packages[@]}"
}

install_dev_tools() {
    write_styled "Section" "Instalando Herramientas de Desarrollo"
    local packages=("gcc" "g++" "clang" "make")
    install_packages "${packages[@]}"

    write_styled "Info" "Instalando NVM (Node Version Manager)..."
    if command -v curl &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    elif command -v wget &>/dev/null; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    else
        write_styled "Warning" "Ni curl ni wget están disponibles para instalar NVM."
    fi
}

install_desktop_tools() {
    write_styled "Section" "Instalando Herramientas de Entorno de Escritorio"
    local packages=("zoxide" "eza")
    if [[ "$OS" == "Linux" ]]; then
        packages+=("rofi" "rxvt-unicode" "i3" "alacritty" "feh")
    elif [[ "$OS" == "Darwin" ]]; then
        # Equivalentes o alternativas para macOS
        packages+=("alacritty") 
        write_styled "Info" "Algunas herramientas como rofi, i3, feh son específicas de Linux y no se instalarán en macOS."
    fi
    install_packages "${packages[@]}"
}

install_zsh_plugins() {
    write_styled "Section" "Instalando Zsh y sus plugins"
    
    # Instalar Zsh
    install_packages "zsh"

    # Instalar Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        write_styled "Warning" "Oh My Zsh ya está instalado. Omitiendo la instalación."
    else
        write_styled "Info" "Instalando Oh My Zsh..."
        if command -v curl &>/dev/null; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        elif command -v wget &>/dev/null; then
            sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        else
            write_styled "Warning" "Ni curl ni wget están disponibles para instalar Oh My Zsh."
            return
        fi
    fi

    local ZSH_CUSTOM_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
    local ZSH_CUSTOM_THEMES="$HOME/.oh-my-zsh/custom/themes"

    # Instalar zsh-autosuggestions
    if [ -d "${ZSH_CUSTOM_PLUGINS}/zsh-autosuggestions" ]; then
        write_styled "Warning" "zsh-autosuggestions ya está instalado."
    else
        write_styled "Info" "Instalando zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM_PLUGINS}/zsh-autosuggestions"
    fi

    # Instalar zsh-syntax-highlighting
    if [ -d "${ZSH_CUSTOM_PLUGINS}/zsh-syntax-highlighting" ]; then
        write_styled "Warning" "zsh-syntax-highlighting ya está instalado."
    else
        write_styled "Info" "Instalando zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM_PLUGINS}/zsh-syntax-highlighting"
    fi

    # Instalar Powerlevel10k
    if [ -d "${ZSH_CUSTOM_THEMES}/powerlevel10k" ]; then
        write_styled "Warning" "Powerlevel10k ya está instalado."
    else
        write_styled "Info" "Instalando Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM_THEMES}/powerlevel10k"
    fi
    
    write_styled "Success" "Instalación de Zsh y plugins completada."
    write_styled "Info" "Por favor, configura tu archivo .zshrc para activar los plugins y el tema."
    write_styled "Info" "Ejemplo de configuración en .zshrc:"
    echo '
# Ejemplo de configuración para .zshrc:
# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
'
}

run_environment_config() {
    write_styled "Section" "Ejecutando script de configuración de entorno"
    local script_url="https://raw.githubusercontent.com/Ebriopes/dotfiles/server/scripts/dotfiles-setup.sh"
    local script_path="/tmp/dotfiles-setup.sh"

    write_styled "Info" "Descargando script desde $script_url..."
    if command -v curl &>/dev/null; then
        curl -L -o "$script_path" "$script_url"
    elif command -v wget &>/dev/null; then
        wget -O "$script_path" "$script_url"
    else
        write_styled "Error" "Se necesita curl o wget para descargar el script."
    fi

    chmod +x "$script_path"
    write_styled "Info" "Ejecutando $script_path..."
    bash "$script_path"
    write_styled "Success" "Script de entorno ejecutado."
}

# --- Menú Principal ---

show_menu() {
    clear
    write_styled "Section" "Instalador de Dotfiles"
    echo "Sistema Operativo: $OS ($DISTRO)"
    echo "Gestor de Paquetes: $PACKAGE_MANAGER"
    echo ""
    echo "Selecciona una opción:"
    echo "  1) Instalar dependencias base (git, curl, stow, etc.)"
    echo "  2) Instalar herramientas de desarrollo (compiladores, nvm, etc.)"
    echo "  3) Instalar herramientas de escritorio (rofi, alacritty, i3, etc.)"
    echo "  4) Instalar plugins de Zsh (oh-my-zsh, p10k, etc.)"
    echo "  5) Instalar TODO"
    echo "  6) Ejecutar script de configuración de entorno"
    echo "  7) Salir"
    echo ""
}

main() {
    detect_os
    
    while true; do
        show_menu
        read -rp "Elige una opción [1-7]: " choice
        case "$choice" in
            1)
                install_base_deps
                ;;
            2)
                install_dev_tools
                ;;
            3)
                install_desktop_tools
                ;;
            4)
                install_zsh_plugins
                ;;
            5)
                write_styled "Section" "Instalando todo..."
                install_base_deps
                install_dev_tools
                install_desktop_tools
                install_zsh_plugins
                ;;
            6)
                run_environment_config
                ;;
            7)
                write_styled "Info" "Operación finalizada."
                break
                ;;
            *)
                write_styled "Warning" "Opción no válida. Por favor, elige entre 1 y 7."
                ;;
        esac
        read -rp "Presiona Enter para continuar..."
    done
}

# --- Punto de Entrada ---
main