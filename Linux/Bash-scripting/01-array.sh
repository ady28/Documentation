#!/usr/bin/env bash

#Declare an array
arr1=(1 2 3 4)
echo ${arr1[*]}
echo ${arr1[2]}
#See the index values
echo ${!arr1[*]}

#Declare empty array
arr2=()

#Sentence array
arr3=("first sentence" "second sentence")

#Define array with index
arr4=([2]=a [5]=b [6]=c)
echo ${arr4[*]}
echo ${!arr4[*]}

#Store command output in array
arr5=($(date))

#Read an array
read -p "Enter array elements separated by space: " -a arr7
echo ${arr7[*]}

#Concatenate arrays
arr6=( ${arr5[*]} ${arr4[*]} )
echo ${arr6[*]}
