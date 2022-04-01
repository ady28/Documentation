#!/bin/bash

ds=$(systemctl status docker | awk '/Active:/ {print $3}' | tr -d '[()]')
dv=$(docker -v | awk '{ print $3 }' | tr -d ',')

echo "The Docker status is: $ds"
echo "The Docker version is: $dv"
