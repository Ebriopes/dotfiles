#!/usr/bin/env sh

clear

os=$(uname -o)
distro=$(lsb_release -i | cut -f 2-)

if [ "$os" != "GNU/Linux" ]; then
	printf "Sorry but I don't know how to manage this OS"
	exit 1
fi

printf "Operative System: %s\nDistribution: %s\n\n" "$os" "$distro"

printf "Hi, I'm your dotfiles installer\n\n"
printf "I will to try install all packages and dependencies need it \nto make your home feel like one \n\n"

if [ "$distro" = "Ubuntu" ]; then
	missing_packages=""
	packages="git curl rofi urxvt"

	for package in ${packages}; do
		dpkg -s "${package}" >/dev/null 2>&1 || missing_packages="${missing_packages} ${package}"
		#printf ${package}
	done

	printf "%s" "$missing_packages"
fi

if [ "$distro" = "ManjaroLinux" ]; then
	missing_packages=""
	packages="git curl rofi urxvt"

	printf "The next packages will be installed: \n%s\n\n" "${packages}"

	#sudo pacman -S ${packages} >/dev/null 2>&1 || missing_packages="${missing_packages} ${packages}"

	sudo pacman -S ${packages}

	#printf "\n\n"

	missing_packages=$(pacman -Qi ${packages} 2>&1 >/dev/null)

	missing_packages=$(echo "${missing_packages}" | awk '{print $4}')

	printf "\n\nMissing packages: \n%s\n\n" "${missing_packages}"


fi

