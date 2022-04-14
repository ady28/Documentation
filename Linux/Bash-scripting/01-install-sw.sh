#!/usr/bin/env bash

#Example: sudo ./01-install-sw.sh vim nginx

#Check root
if [[ $(id -u) -ne 0 ]]
then
	echo "You have to run the script as root or with sudo"
	exit 1
fi

if [[ $# -eq 0 ]]
then
	echo "You have to pass at least one package name: sudo ./01-install-sw.sh vim nginx"
	exit 2
fi

for pkg in $@
do
	echo "Current package is $pkg"
	if which $pkg &> /dev/null
	then
        	echo "$pkg is already installed"
	else
		echo "Installing $pkg"
		apt update -y &> /dev/null && apt install -y $pkg &> /dev/null
		if [[ $? -ne 0 ]]
        	then
                	echo "$pkg was not installed."
        	else
                	echo "$pkg was installed"
        	fi
	fi
done

<< comm
#Check sw is not installed
if which vim &> /dev/null
then
	echo "vim is already installed"
else
	echo "Installing vim"
	apt update -y &> /dev/null && apt install -y vim &> /dev/null
	if [[ $? -ne 0 ]]
	then
		echo "vim was not installed."
	else
		echo "vim was installed"
	fi
fi
comm
