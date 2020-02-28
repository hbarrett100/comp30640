#!/bin/bash


#if number of parameters given is not equal to two then print error message to user and exit
if [ $# -ne 2 ]; then
	echo "Error: parameters problem"
	exit 1

#if user directory does not exist then print error message to user and exit
elif [ ! -d $1 ]; then
	echo "Error: user does not exist"
	exit 1
fi
 
#execute P.sh to enter semaphore. File path to service within user directory given as argument to semaphore"
./P.sh "$1/$2"

#if service does not exist then execute V.sh to exit semaphore and exit script
if [ ! -e "$1"/"$2" ]; then
	./V.sh "$1/$2"
	echo "Error: service does not exist"
	exit 1
else 	
	
	#else use rm -r to delete service directory or service file as requested
	#exit script successfully
	rm -r "$1/$2"
	./V.sh "$1/$2"
	echo "service removed"
	exit 0
fi
