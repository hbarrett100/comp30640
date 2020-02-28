#!/bin/bash

#if number of parameters given is not equal to two print error message to user
if [ $# -ne 2 ]; then
	echo "parameters problem"
	#exit code that tells something went wrong
	exit 1

#If the user directory does not exist then print error message to user and exit
elif [ ! -d "$1" ]; then
	echo "user does not exist"
	exit 1

#if service does not exist then print error message to user and exit
elif [ ! -e "$1/$2" ]; then
	echo "service does not exist"
	exit 1

else

	#else execute P.sh to enter semaphore and use the cat command to show the contents of the file
	./P.sh "$1/$2"
	cat "$1/$2"
	#execute V.sh to exit semaphore
	./V.sh "$1/$2"
	exit 0
fi 
