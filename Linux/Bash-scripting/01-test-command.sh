#!/bin/bash

clear
read -p "Enter first number: " n1
read -p "Enter second number: " n2
read -p "Enter first string: " s1
read -p "Enter second string: " s2
test $n1 -eq $n2
echo "Test result for equal was $?"
[[ $n1 -gt $n2 ]]
echo "Test result for greater than was $?"
[[ -z $s1 ]]
echo "Is first string of length 0? $?"
[[ -n $s2 ]]
echo "Is the second string of length ge than 1? $?"
[[ $s1 == $s2 ]]
echo "The result for string equal test wax $?"
[[ $s1 != $s2 ]]
echo "The result for string not equal test wax $?"
