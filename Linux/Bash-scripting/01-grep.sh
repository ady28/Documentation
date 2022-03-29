#!/bin/bash

#Search for word in a file
grep help /etc/os-release
#Ignore case
grep -i ubuntu /etc/os-release
#Find this exact word
grep -w LT /etc/os-release
#Print only the match and not the entire line
grep -o ubuntu /etc/os-release
#Show line number
grep -n ubuntu /etc/os-release
#Show number of lines matched
grep -c ubuntu /etc/os-release
#Show file names and the line where the pattern matches
grep -r "ubuntu" /etc
#Show only file names where the pattern matches
grep -rl "ubuntu" /etc

#Place 2 search terms in a file and use grep to search for them in another one
echo "ubuntu" >> search
echo "Focal" >> search
grep -f search /etc/os-release
#Search for multiple words
grep -e 'ubuntu' -e 'Focal' /etc/os-release
grep -E 'ubuntu|Focal' /etc/os-release

#Get lines that start with
grep -E '^UBUNTU' /etc/os-release
#Get lines that end with
grep -E 'focal$' /etc/os-release
#Get empty lines
grep -E '^$' /etc/os-release
#Match special characters
grep -E "Fossa)\"" /etc/os-release
grep -E 'Fossa)"' /etc/os-release
#Match any one character with .
grep -E 'f.cal' /etc/os-release
#Find the word version
grep -Ei "version\b" /etc/os-release
#The _ is optional and can appear once
grep -Ei "_?name" /etc/os-release
#The _ is optional and can appear more than once
grep -Ei "_*name" /etc/os-release
#The _ has to appear at least once
grep -Ei "_+name" /etc/os-release
#Find the lines that have either of the letters
grep -E "[Nu]" /etc/os-release
#Find the lines that have any of the letters in the interval
grep -E "[A-N]" /etc/os-release
#Find the lines that have any of A to D and N to Z
grep -E "[A-DN-Z]" /etc/os-release
#Find asss in text
grep -E "as{3}" /etc/os-release

#Find directories
ls -la / | grep -E "^d"

#Find IPv4 addresses
echo "ip is 10.3.4.3 and 1.2.3.4 and 1111.4.5.2" | grep -E "\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b"
