#!/usr/bin/env bash

id=$(id -u)
if [[ $id -eq 0 ]]
then
        echo "You are root"
else
        echo "You are not root"
        if id | grep sudo > /dev/null
        then
                echo "You can use sudo"
        else
                echo "You cannot use sudo"
        fi
fi
