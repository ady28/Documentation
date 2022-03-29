#!/bin/bash

#Read text starting from line 2
more +2 /etc/os-release
#Read first 3 lines
more -3 /etc/os-release

#Read top 2 lines
head -2 /etc/os-release
#Read top 10 lines
head /etc/os-release
#Read last 2 lines
tail -2 /etc/os-release
#Read last 10 lines
tail /etc/os-release
#Read lines 3-5
head -5 /etc/os-release | tail -3
awk 'NR>=3 && NR<=5 {print}' /etc/os-release
sed -n '3,5p' /etc/os-release
