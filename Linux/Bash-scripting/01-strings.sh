#!/bin/bash

#Get length of string
s1="test"
echo "${#s1}"

#Concatenation
s2='Test'
s3=$s1$s2
echo $s3

#Convert to lower or upper
s4=${s1^^}
echo $s4
s5=${s2,,}
echo $s5

#Replace part of string
s6="Just a test"
s7=${s6/a test/something}
echo $s7

#Display part of string
s8='Something interesting'
echo ${s8:1:5}

#Display the full path of a file
realpath 01-install-docker.sh

#Get the file name from a full path
basename /etc/hosts
#Also strip any suffix
basename /etc/resolv.conf .conf

#Get the directory name for a file
dirname /etc/hosts
