#!/usr/bin/env bash

if [[ $# -ne 2 ]]
then
	echo "Please enter the 2 needed args!"
	exit 1
fi

echo "You gave the arg: $1"
echo "The other arg is $2"
