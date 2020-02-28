#!/bin/bash

#if the number of parameters given is less than two then print an error message to user and exit
if [ $# -lt 2 ]; then
	echo "Not enough parameters given"
	exit 1
fi

#if the client pipe already exists then tell user than id is already using the server
if [ -p "$1.pipe" ]; then
	echo "This id is already using the server" 
	exit 1
fi

#if client pipe does not exist then make pipe using mkfifo
if [ ! -p "$1.pipe" ]; then 
	mkfifo $1.pipe
fi

#case construct to check if the second argument given is one of the below cases
#all cases contain parameters check to ensure correct number of parameters given by user
#in all cases response from server via $1.pipe is read using the cat command
case "$2" in
	init)
		if [ $# -ne 3 ]; then
			echo "Error. Parameters problem" 
		else
			#send all arguments to server via server pipe
			echo "$@" >"server.pipe" 
			cat "$1.pipe"
		fi
	;;
	insert)

		if [ $# -ne 4 ]; then
			echo "Error. Parameters problem"
		else
		 	#request login and password from user and read both
			echo "Please write Login:"
			read login
			echo "Please write password:"
			read password	
			#send all arguments to server via server pipe
			echo "$1" "$2" "$3" "$4" "${login} \n${password}" >"server.pipe"
			
			#read response from server
			cat "$1.pipe"
		fi
	;;
	generate)
		if [ $# -ne 4 ]; then
			echo "Error. Parameters problem"
		else
			echo "Please write login:"
			read login
			#generate 15 digit random password 
			password=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c15)
			#tell the user what their random password is
			echo "Your randomly generated password is: $password"
			#send insert request to server
			echo "$1" "insert" "$3" "$4" "${login} \n${password}" >"server.pipe"
			cat "$1.pipe"
		fi
	;;
	show)
		#if number of arguments is not equal to 4 then print error message to user
		if [ $# -ne 4 ]; then
			echo "Error. Parameters problem"
		else
			#send all arguments to server via server pipe
			echo "$@" >"server.pipe"

			#set newline as the internal field separator
			IFS=$'\n'
			
			#create a variable called payload which contains the content of the client pipe
			payload=`cat "$1.pipe"`
			
			#if error message if given by server then print error message from user
			if [ "$payload" = "user does not exist" ] || [ "$payload" = "service does not exist" ]; then
				echo $payload
			else
				#initialise line to zero
				lineNum=0

				#for loop to loop through lines in the payload sent back from the server
				for line in $payload; do

					#the first line in the payload is equal to the login
					if [[ $lineNum -eq 0 ]]; then
						echo "$3's login for $4 is: $line"

					#second line in the payload is the password
					elif [[ $lineNum -eq 1 ]]; then
						echo "$3's password for $4 is: $line"
					else
						echo "$line"
					fi
					#increment the line number in the payload in each loop
					lineNum=$((lineNum+1))
				done
			fi
		fi
	;;
	ls) 
		#if number of parameters is not equal to 3 or 4 then print error message to user	
		if [ $# -lt 3 ] ;then
			echo "Error. Parameters problem"
		elif [ $# -eq 3 ]; then
			echo "$@">"server.pipe"
			cat "$1.pipe"
		elif [ $# -eq 4 ]; then
			#send all arguments to server via server pipe
			echo "$@">"server.pipe"
			#print response from server to user
			cat "$1.pipe"
		fi
			
	;;
	edit) 
		#if number of arguments given is not equal to 4 then print error message to user
		if [ $# -ne 4 ]; then
			echo "Error. Parameters problem"
		
		else
			#send show request to server
			echo "$1" "show" "$3" "$4" >"server.pipe"
			
			#create temporary file
			tempfile=$(mktemp)
			
			#create variable which contains the resonse of the show request from the server
			showcontent=`cat "$1.pipe"`

			#if server sends error message then print error message to user
			if [ "$showcontent" = "service does not exist" ] || [ "$showcontent" = "user does not exist" ]; then  	
				echo "$showcontent"
				exit 1

			fi
			#print the response of the show request into the temporary file
			echo "$showcontent" > "$tempfile"

			vim $tempfile

			#create variable called payload and assign it to an empty string
			payload=""

			#read content of tempfile as an array. Newline is internal field separater. Delimiter is empty string. 
			IFS=$'\n' read -d '' -r -a lines < "$tempfile"
			
			#for loop to loop through lines in the temporary file
			for line in "${lines[@]}"
				do
					#add each line to the payload and add an newline character at end of each line
					 payload+="${line}\n"
			done
			#send update request to server
			echo "$1 update $3 $4 $payload">"server.pipe"
			
			#print response from server to user
			cat "$1.pipe"
			#delete the temporary file
			rm ${tempfile} 
		fi
	;;
	rm) 

		if [ $# -ne 4 ]; then
			echo "Error. Parameters problem"
		else 
			#send all arguments to server via server pipe
			echo "$@" >"server.pipe"
			cat "$1.pipe"
		fi
	;;
	shutdown) 
		echo "$@" >"server.pipe"
		cat "$1.pipe"	
	;;
	*) 
		#if none of cases met, print to user that bad request given
		echo "Error: bad request"
		exit 1
	;;
esac
#delete the client pipe
rm $1.pipe




