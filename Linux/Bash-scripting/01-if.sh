#!/usr/bin/env bash

if [[ 1 -eq 1 ]]
then
	echo "1 is equal to 1"
fi

if [[ 1 -eq 2 ]]
then
	echo "1 is equal to 2"
else
	echo "1 is not equal to 2"
fi

if [[ 1 -eq 2 ]]
then
	echo "1 is not equal to 2"
elif [[ 1 -eq 3 ]]
then
	echo "1 is not equal to 3"
else
	echo "1 is equal to something else"
fi
