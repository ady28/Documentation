#!/usr/bin/env bash

servers=(192.168.1.234 192.168.1.235 192.168.1.236)
cmds=("hostname" "uptime" 'free -m')

for server in ${servers[@]}
do
	echo "#### Executing commands for $server"
	for cmd in "${cmds[@]}"
	do
		echo "#    Executing command: $cmd"
		ssh -o StrictHostKeyChecking=No user100@$server $cmd
	done
done
