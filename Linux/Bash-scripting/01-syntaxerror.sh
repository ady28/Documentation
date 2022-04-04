#!/usr/bin/env bash

#This makes the script actually not execute but flag all syntax errors
set -n

#Working command
echo "First command"

#Command that makes execution error
assadd

#Command that makes syntax error
echo $(username
