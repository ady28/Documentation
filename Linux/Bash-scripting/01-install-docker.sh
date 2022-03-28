#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then
	echo "Please run this script from root only"
	exit 1
fi

#   Get the os-release text, keep only the lines that contain NAME= and select only the first one, then print out
# the third value of the matches which is the OS (first is the whole line, then is NAME, then the OS name),
# after that, pipe the result to tr to strip the " character, then pipe again to tr to tranform uppercase letters
# into lowercase
if [[ $(cat /etc/os-release | awk -F= '/NAME=/  && NR==1 { print $2 }' | tr -d '"' | tr [A-Z] [a-z] ) -ne ubuntu ]]
then
	echo "This script works for only ubuntu"
	exit 2
fi

echo "###################################################################################"
echo "# OS is identified as Ubuntu                                                      #"
echo "# This Script will remove old docker components and install latest stable docker  #"
echo "###################################################################################"
sleep 1
echo "==> Removing older version of docker if any...."
apt remove docker docker-engine docker.io containerd runc -y &> /dev/null

echo "==> Updating exiting list of packagesss..."
apt update -y &> /dev/null

echo "==> Installing dependencies......."
apt install apt-transport-https ca-certificates curl gnupg lsb-release -y &> /dev/null

echo "==> Adding the GPG key for the official Docker repository to your system..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -x "http://192.168.1.254:80" | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "==> Adding the Docker repository to APT sources:.."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==> Update the package database with the Docker packages from the newly added repo..."
apt update -y &> /dev/null

echo "==> Now installing docker....."
apt install docker-ce docker-ce-cli containerd.io -y &> /dev/null

if [[ $? -ne 0 ]]
then
	echo "====>  Sorry Failed to install Docker. Try it manually  <===="
	exit 2
fi

echo "====>  Docker has been installed successfully on this host - $(hostname -s)  <===="
if [[ $(systemctl is-enabled docker) -eq 'disabled' ]]
then
        echo "====>  Docker is disabled... Enabling and starting it  <===="
        systemctl enable docker &> /dev/null
        systemctl start docker &> /dev/null
elif [[ $(systemctl is-active docker) -eq 'inactive' ]]
then
        echo "====>  Docker is stopped... Starting it  <===="
        systemctl start docker &> /dev/null
else
        echo "====>  Docker is already enabled and started... You can start using it  <===="
fi

echo "====>  Giving the user user100 rights to run Docker without sudo"
usermod -aG docker user100

echo "====>  Configuring Docker proxy"
mkdir -p /etc/systemd/system/docker.service.d
echo -e "[Service]\nEnvironment=\"HTTP_PROXY=http://192.168.1.254:80\"\nEnvironment=\"HTTPS_PROXY=http://192.168.1.254:80\"\nEnvironment=\"NO_PROXY=localhost,127.0.0.1,::1\"" > /etc/systemd/system/docker.service.d/proxy.conf
systemctl daemon-reload &> /dev/null
systemctl restart docker &> /dev/null

echo "====>  Configuring Docker client proxy for user100"
mkdir /home/user100/.docker
echo -e "{\n \"proxies\":\n {\n  \"default\":\n  {\n   \"httpProxy\": \"http://192.168.1.254:80\",\n   \"httpsProxy\": \"http://192.168.1.254:80\",\n   \"noProxy\": \"*.testcorp.local,localhost,127.0.0.1\"\n  }\n }\n}" > /home/user100/.docker/config.json
