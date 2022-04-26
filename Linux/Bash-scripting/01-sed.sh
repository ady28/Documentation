#!/usr/bin/env bash

#print lines 2 to 4
sed -n '2,4p' /etc/passwd

#print lines which contain root
sed -n '/root/p' /etc/passwd

#print lines which contain root or user
sed -n -e '/root/p' -e '/user/p' /etc/passwd
