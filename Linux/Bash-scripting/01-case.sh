#!/bin/bash

case $1 in
	'test')
		echo "Executing in test"
		echo "Done"
		;;
	'prod')
		echo "Be careful, boy! This is production you are playing with!"
		;;
	*)
		echo "Just a default message"
		;;
esac
