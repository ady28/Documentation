#!/bin/bash

#Print version of the Docker service
docker version | awk 'NR==13 { print $2}'
#Separate by either of the 2 characters / or :
docker version | awk -F '[/:]' 'NR==7 { print $4 }'
