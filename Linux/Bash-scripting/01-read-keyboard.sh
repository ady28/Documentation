#!/bin/bash

#Read text and echo it
read -p 'Enter text: ' a
echo $a

#Read secret text
read -p 'Enter test: ' -s b
echo $b
