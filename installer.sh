#!/usr/bin/env sh

clear

echo "Hi, I'm your dotfiles installer \nI will to try install all packages and dependencies need it to make your home feel like one";

os=$(uname -o);
distro=$(lsb_release -i|cut -f 2-);

if [ $os != "GNU/Linux" ];then
	echo "Sorry but I don't know how to manage this OS"
	exit 1
fi

if [ $distro = "Ubuntu" ];then
	missing_packages=""
	packages="git curl rofi urxvt"
	
	for package in "${packages}";do
		dpkg -s ${package} > /dev/null 2>&1 || missing_packages="${missing_packages} ${package}"
		#echo ${package}
	done

	echo $missing_packages
fi

echo $os $distro
