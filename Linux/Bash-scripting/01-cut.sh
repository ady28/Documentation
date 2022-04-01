#Get first character from file
cut -c 1 /etc/os-release
#Get the 1st and 4th character from file
cut -c 1,4 /etc/os-release
#Get characters from 1 to 4
cut -c 1-4 /etc/os-release
#Get characters from 1 to 4 and the 6th
cut -c 1-4,6 /etc/os-release
#Get characters from 4 to the end of the line
cut -c 4- /etc/os-release

#Get first field from file where separator is =
cut -d "=" -f 1 /etc/os-release
#Get first 2 fields from file where separator is = and display them with separator space
cut -d "=" -f 1,2 /etc/os-release --output-delimiter=" "

#Get docker version
docker -v | cut -d " " -f 3 | tr -d ','
