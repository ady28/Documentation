#!/usr/bin/env bash

#Associative arrays must be declared before using them
declare -A assocarray1
assocarray1=([name]='Adi' [age]=35 [gender]='Male')
echo ${assocarray1[*]}
echo ${assocarray1[age]}

#You can also add values like so
assocarray1[work]='Yes'

echo ${assocarray1[*]}
