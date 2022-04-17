#!/usr/bin/env bash

cnt=0
while true
do
	if [[ $cnt -eq 2  ]]
	then
		break
	fi
	echo "Do"
	echo "---"
	sleep 1
	((cnt++))
done

while IFS="," read f1 f2
do
	echo "$f1"
done < testinfo.txt
