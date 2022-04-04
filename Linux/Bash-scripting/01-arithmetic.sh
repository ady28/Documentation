#!/bin/bash

#integer operations
x=2
y=4
((sum=x+y))
echo $sum
((sub=x-y))
echo $sub
((mul=x*y))
echo $mul
((div=x/y))
echo $div
((rem=x%y))
echo $rem
((x++))
echo $x

#Float operations
#Install the bc package
x=5.4
y=3.3
bc<<<"$x+$y"
