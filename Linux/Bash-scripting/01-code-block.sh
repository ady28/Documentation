#!/usr/bin/env bash

{
ls /
pwd
date
}

which docker && { echo "Docker is installed!" ; echo "Docker version is: $(docker --version)" ; } || echo "Docker is not installed!"
