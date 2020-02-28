#!/bin/bash


#check if server pipe exists. If not, create it using mkfifo command 
if [ ! -p "server.pipe" ]; then
	mkfifo "server.pipe"
fi


#endless while loop
while true; do

	#read commands from server pipe into an array
	read -r -a array < "server.pipe"
	#check if array is empty. If it is, return to top of loop to read from pipe again.
	if [ ${#array[@]} -eq 0 ]; then
		continue
	else
		#case construct to check if second element in array is one of the below cases
		#in all cases send response of script down the client id pipe
		# & added to execute the commands in the background
		case "${array[1]}" in

			#give appropriate elements of array as arguments to each script
			init)	
				./init.sh "${array[@]:2}" > "${array[0]}.pipe"  &
			;; 			
			insert)

				#give second element, third element, an empty string and the remaining elements
				#from the fifth onwards as arguments to the insert script
				./insert.sh "${array[2]}" "${array[3]}" '' "${array[*]:4}" >"${array[0]}.pipe" &
			;;
			show)
				./show.sh "${array[@]:2}" >"${array[0]}.pipe" &
			;;
			update)
				#give second element, third element, the string "f" and the remaining elements 
				#from the fifth onwards as arguments to the insert script
				./insert.sh "${array[2]}" "${array[3]}" "f" "${array[*]:4}" >"${array[0]}.pipe" &
			;;
			rm)

				./rm.sh	"${array[@]:2}" >"${array[0]}.pipe" &
			;;
			ls)

				./ls.sh "${array[@]:2}" >"${array[0]}.pipe" &
			;;
			shutdown)

				#tell user server is shutting down, delete server pipe and exit script
				echo "server shutting down" >"${array[0]}.pipe" &
				rm "server.pipe"
				exit 0
			;;
			*)
				#if the second element of the array is anything other than the above cases then
				#tell user a bad request was given, remove pipe and exit script
				echo "Error: bad request"
				rm "server.pipe" 
				exit 1
			;;
		esac
		echo "Next request please"
	fi
done

 

