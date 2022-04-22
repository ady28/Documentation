#!/bin/bash

#Print version of the Docker service
docker version | awk 'NR==13 { print $2}'
#Separate by either of the 2 characters / or :
docker version | awk -F '[/:]' 'NR==7 { print $4 }'

#The action in the {} is executed for each line of the input
awk '{ print "ok" }' /etc/passwd

#Print the current line number
awk '{ print NR}' /etc/passwd

#Print number of fields on each line
awk '{ print NF }' /etc/passwd

#Print line number and number of fields on that line
awk '{ print NR,NF }' /etc/passwd

#Use BEGIN and END to print helpful messages and find lines with /root/ in them
awk 'BEGIN {print "Starting processing of file:"} /root/ {print $0} END {print "Done processing file"}' /etc/passwd

#Put that logic in a script file and run it
awk -f awk-test.awk /etc/passwd
