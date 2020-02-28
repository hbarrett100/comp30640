#!/bin/bash

#if four parameters were not given then print error message to user and exit
if [ $# -ne 4 ]; then
	echo "parameters problem"
	exit 1

#if the user directory does not exist then print error message to user and exit
elif [ ! -d "$1" ]; then
	echo "user does not exist"
	exit 1 
fi 

#first semaphore is to check if service includes a directory. This is made first if required.
#The step is added so that $2 can be passed to the second semaphore below. Lock cannot be made if folder doesnt exist. 

./P.sh "$1"

#create a variable called filename and assign it to the secod argument given to the script
filename="$2"

dir_name=`dirname "$filename"`

#if dir_name is not equal to "." then it is a directory. If directory doesn't exist then create it.
if [ "$dir_name" != "." ]; then

	if [ ! -d "$1/$dir_name" ]; then

		# -p will make parent directories for service as required
		mkdir -p "$1/$dir_name"
	fi
fi
#execute V.sh to exit semaphore
./V.sh "$1"

#now that the service folder has been created if required, it can be passed to the second P.sh
#execute P.sh to enter semaphore

./P.sh "$1/$2"
#if the service exists and the third parameter is not equal to "f" then tell user service exists and exit
if [ -e "$1/$2" ] && [ "$3" != "f" ]; then
	echo "service already exists"
	./V.sh "$1/$2"
	exit 1

#if the service exists and the third parameter is equal to "f" then overwrite the service file with the updated payload
elif [ -e "$1/$2" ] && [ "$3" == "f" ]; then

	echo -e "$4\n" > "$1/$2" 
	./V.sh "$1/$2"
	echo "OK: service updated" 
	exit 0

#if the service does not exist then create the service file using the touch command
elif [ ! -e "$1/$2" ]; then
	touch "$1/$2"
	#append the payload to the service file
	echo -e "$4\n" >> "$1/$2"
	./V.sh "$1/$2"
	echo "OK:service created"
	exit 0
fi

