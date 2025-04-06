#!/usr/bin/env bash

clear

os=$(uname -s)
distro=$(
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
        elif [ -r /etc/lsb-release ]; then
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
printf "[1;32mHi, I'm your dotfiles installer!\nI will try to install all the necessary packages and dependencies to make your home feel like one.\n\n[0m"

install_packages() {
    local package_manager="$1" packages="$2" missing_packages=""
    printf "[1;33mChecking for required packages (%s)...\n[0m" "$package_manager"
    
    for package in $packages; do
        printf "  Checking %s...\n" "$package"
        if ! type "$package" &>/dev/null; then
            missing_packages+="$package "
        fi
    done
    
    if [ -n "$missing_packages" ]; then
        printf "[1;33mThe following packages will be installed using %s: \n%s\n\n[0m" "$package_manager" "$missing_packages"
        case "$package_manager" in
            "apt-get") sudo apt-get -y install $missing_packages ;;
            "pacman") sudo pacman -Sy --noconfirm $missing_packages ;;
            "apk") sudo apk add --no-cache $missing_packages ;;
            *) printf "[1;31mError: Unsupported package manager: %s\n[0m" "$package_manager"; return 1 ;;
        esac
        printf "[1;32mPackages installed successfully!\n[0m"
    else
        printf "[1;32mAll required packages for %s are already installed.\n[0m" "$package_manager"
    fi
}

case "$distro" in
    ubuntu|debian) install_packages "apt-get" "git curl gcc g++ clang make rofi rxvt-unicode" ;;
    manjaro|arch) install_packages "pacman" "git curl gcc g++ clang make rofi rxvt-unicode" ;;
    alpine) install_packages "apk" "git curl gcc g++ clang make rofi rxvt-unicode" ;;
esac

install_nvm() {
    printf "[1;33mInstalling NVM...\n[0m"
    if command -v curl &>/dev/null; then
        installer="curl -o-"
        elif command -v wget &>/dev/null; then
        installer="wget -qO-"
    else
        printf "[1;31mError: Neither curl nor wget are available. Please install one of them to proceed with NVM installation.\n[0m"
        return 1
    fi
    printf "[1;34mUsing %s to install NVM...\n[0m" "${installer%" -o-"}"
    $installer https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    printf "[1;32mNVM installed successfully!\n[0m"
}

install_nvm

printf "[1;34mDownloading original installer script...\n[0m"
# temp_dir=$(mktemp -d) || { printf "[1;31mError: Failed to create temporary directory.\n[0m"; exit 1; }
printf "[1;34mDownloading to %s...\n[0m" "${PWD}"

(
    # cd "$temp_dir" || { printf "[1;31mError: Failed to change to temporary directory.\n[0m"; exit 1; }
    wget -O original-installer.sh https://raw.githubusercontent.com/Ebriopes/dotfiles/server/original-installer.sh || { printf "[1;31mError: Failed to download original-installer.sh.\n[0m"; exit 1; }
    chmod +x original-installer.sh
    printf "[1;34mExecuting original-installer.sh...\n[0m"
    ./original-installer.sh
)

# printf "[1;34mCleaning up...\n[0m"
# rm -rf "$temp_dir"
