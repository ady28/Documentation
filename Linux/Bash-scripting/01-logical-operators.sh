#!/usr/bin/env bash

read -p "Enter number: " num

if [[ $num -ge 30 && $num -le 100 ]]
then
	echo "Number between 30 and 100"
else
	echo "Number not in 30-100 interval"
fi

if [[ $num -eq 54 || $num -eq 33 ]]
then
	echo "Number is either 54 or 33"
else
	echo "Number is neither 54 nor 33"
fi
