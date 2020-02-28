#!/bin/bash

#check that one parameter has been given
if [ $# -ne 1 ]; then
	echo "Error: parameters problem"
	exit 1

fi

#sempahore positioned outside check to see if user exists
./P.sh "$1"

#if user directory already exists then print error message to user and exit. 
#if not then create the user directory and exit successfully
if  [ -d "$1" ]; then
	echo "Error: user already exists"
	./V.sh "$1" 
	exit 2
else
	mkdir $1
fi
#V.sh will only ever be executed once
./V.sh "$1"
	echo "OK: user created"
	exit 0

