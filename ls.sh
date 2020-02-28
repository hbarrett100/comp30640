#!/bin/bash


#if number of parameters is less than one or greater than two then print error message to user
if [ $# -lt 1 ]; then
	echo "parameters problem"
	#exit code which shows something in the script went wrong
	exit 1
elif [ $# -gt 2 ]; then
	echo "parameters problem"
	exit 1

#if user directory does not exist then print error message to user and exit script
elif  [ ! -d "$1" ]; then	
	echo "user does not exist"
	exit 1

#if service folder does not exist then print error message to user and exit script
elif  [ ! -d "$1/$2" ]; then
	echo "folder does not exist"
	exit 1

else
 	
	echo "OK: "

	#if number of parameters given is one then use tree command
	# to show structured view of file system within user directory
	if [ $# == 1 ] ;then
		tree "$1"

	#if number of parameters given is two then use tree command
	#to show structured view of file system within the service folder given
	elif [ $# == 2 ];then
		tree "$1/$2"
	fi
	exit 0
fi
