#!/bin/bash

#Interpret \ commands
echo -e "Test\nTest"

#Display red color text and at the end reset the color so the prompt does not remain with the red color
echo -e "\033[0;31mTest\033[0m"
echo -e "\033[0;34mTest\033[0m"
