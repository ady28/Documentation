#!/usr/bin/env bash

for each in 1 2 3 4 5
do

echo "In a wild loop!!"

done


for each in '/var/www/html/index.nginx-debian.html' '/etc' '/mnt'
do
	if [[ -x $each ]]
	then
		echo "$each has execute permissions."
	else
		echo "$each does not have execute permissions."
	fi
done


for each in $(ls)
do
        if [[ -x $each ]]
        then
                echo "$each has execute permissions."
        else
                echo "$each does not have execute permissions."
        fi
done

for (( i=0; i <= 10; i++ ))
do
	echo "$i"
done

cnt=0
for (( ;; ))
do
	echo "Infinity loop...war"
	((cnt++))
	if [[ $cnt -eq 10 ]]
	then
		break
	fi
	sleep 3
done
