#!/usr/bin/env bash

#Check if file has x permission
[[ -x /var/www/html/index.nginx-debian.html ]]
echo $?
