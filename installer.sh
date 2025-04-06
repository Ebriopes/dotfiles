#!/usr/bin/env bash
# Usamos /usr/bin/env bash para asegurar que se use bash, que es más portable que sh.

clear

os=$(uname -s)
distro=$(
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID"
        elif [ -f /etc/lsb-release ]; then
        lsb_release -i | cut -d'=' -f2
    else
        echo "Unknown"
    fi
)

if [[ "$os" != "Linux" ]]; then
    printf "[1;31mError: This script only supports Linux-based operating systems.\n[0m"
    exit 1
fi

printf "[1;34mOperative System: %s\nDistribution: %s\n\n[0m" "$os" "$distro"

printf "[1;32mHi, I'm your dotfiles installer!\n[0m"
printf "[1;32mI will try to install all the necessary packages and dependencies to make your home feel like one.\n\n[0m"

# Función para manejar la instalación de paquetes, para no repetir código.
install_packages() {
    local package_manager="$1"
    local packages="$2"
    local missing_packages=""
    local installed_packages=""
    
    printf "[1;33mChecking for required packages (%s)...\n[0m" "$package_manager"
    
    # Detectar paquetes ya instalados de la manera correcta para cada gestor.
    for package in $packages; do
        printf "  Checking %s...\n" "$package"
        case "$package_manager" in
            "apt-get")
                dpkg -s "$package" >/dev/null 2>&1 || missing_packages+="$package "
            ;;
            "pacman")
                pacman -Q "$package" >/dev/null 2>&1 || missing_packages+="$package "
            ;;
            "apk")
                apk info -e "$package" >/dev/null 2>&1 || missing_packages+="$package "
            ;;
            *)
                printf "[1;31mError: Unsupported package manager: %s\n[0m" "$package_manager"
                return 1
            ;;
        esac
    done
    
    if [ -n "$missing_packages" ]; then
        printf "[1;33mThe following packages will be installed using %s: \n%s\n\n[0m" "$package_manager" "$missing_packages"
        # Instalar solo los paquetes faltantes.
        case "$package_manager" in
            "apt-get"|"pacman") # Esta es la línea que nos interesa
                sudo $package_manager -y install $missing_packages
            ;;
            "apk")
                $package_manager add --no-cache $missing_packages
            ;;
            *)
                printf "[1;31mError: Unsupported package manager: %s\n[0m" "$package_manager"
                return 1
            ;;
        esac
        printf "[1;32mPackages installed successfully!\n[0m"
    else
        printf "[1;32mAll required packages for %s are already installed.\n[0m" "$package_manager"
    fi
}

if [ "$distro" = "Ubuntu" ] || [ "$distro" = "Debian" ]; then
    install_packages "apt-get" "git curl gcc g++ clang make rofi urxvt"
    elif [ "$distro" = "Manjaro" ] || [ "$distro" = "Arch" ]; then
    install_packages "pacman" "git curl gcc g++ clang make rofi urxvt"
    elif [ "$distro" = "alpine" ]; then
    install_packages "apk" "git curl gcc g++ clang make rofi rxvt-unicode"
fi

printf "[1;34mRunning original installer script...\n[0m"

bash ${PWD}/dotfiles/original-installer.sh # Ejecuta el script original
