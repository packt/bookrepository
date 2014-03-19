#!/bin/bash
#byLeal

function dohelp(){
	echo "+-------------------------------------------------------------+"
	echo "| Simple script to create users on the AD/DC (Samba 4 Server) |"
	echo "|                                        Implementing Samba 4 |"
	echo "|                                                             |"
	echo "|                              Copyright(c) 2013 Marcelo Leal |"
	echo "+-------------------------------------------------------------+"
	echo " Usage:"
	echo ""
	echo " \"-h\" for this help message"
	echo " \"-c\" creates users (silently)."
	echo " \"-v\" creates users (verbosely)," 
	echo "        showing the actual add user commands."
	echo ""
	echo " To create the users, the script uses a file named users.txt"
	echo " that needs to be in the current directory."
	echo ""
	echo " Error Codes: 	(0)OK," 
	echo "			(1)Wrong Options," 
	echo "			(2)At least one user creation error,"
	echo "			(3) Could not open users.txt file."
}

function docreate() {
        # Our arg...
        verbose=$1
	# Some variables to save the possible processing errors...
	TOTALE=0; TOTALP=0; TOTALG=0
	# Do we have the users.txt file?
	if [ ! -f ./users.txt ]; then
		echo "-> ERROR: Could not find users.txt file.";
		exit 3;
	fi
	while IFS=" " read first last
	do
		let TOTALG=TOTALG+1;
		# Just process the line if we have Name AND Surname...
		if [ `echo "$first $last" | wc -w` -eq 2 ]; then
			# At least 2 letters for Name and Surname...
			if [ `echo "$first" | wc -c` -gt 2 ] && [ `echo "$last" | wc -c` -gt 2 ]; then
				#Initialize some variables...
				name="${first[@]^}"
				surname="${last[@]^}"
				initials="${name::1}${surname::1}"
				username=`echo "${name::1,2}${surname}" | tr [:upper:] [:lower:]`
				# Execute the command to actually create the user...
				if [ $verbose == "-v" ]; then
					echo "/usr/local/samba/bin/samba-tool user add \"$username\" \'pa\$\$w0rd!\'  --userou=\"ou=Standard Users,ou=People\" \
					--surname=\"$surname\" --given-name=\"$name\" --initials=\"$initials\"  --company=\"EALL\" \
					--description=\"Standard User\" --must-change-at-next-login --mail-address=\"$username@eall.com.br\""
				fi
				eval /usr/local/samba/bin/samba-tool user add \"$username\" \'pa\$\$w0rd!\'  --userou=\"ou=Standard Users,ou=People\" \
				     --surname=\"$surname\" --given-name=\"$name\" --initials=\"$initials\"  --company=\"EALL\" \
				     --description=\"Standard User\" --must-change-at-next-login --mail-address=\"$username@eall.com.br\" >/dev/null 2>&1
				if [ $? -eq 0 ]; then
					echo "User: $username created	OK."
					let TOTALP=TOTALP+1;
				else
					echo "-> ERROR Creating User: \"$username\"."
					let TOTALE=TOTALE+1;
				fi
			else
				echo "-> ERROR Processing: \"$first $last\". Name and Surname must be greater than 1 letter (each)...";
				let TOTALE=TOTALE+1;
			fi
		else
			echo "-> ERROR Processing: \"$first $last\". Name AND Surname are required...";
			let TOTALE=TOTALE+1;
		fi;	
	done <./users.txt
	echo "--------------------------"
	echo "Total Users Created..: $TOTALP"
	echo "Total Creation Errors: $TOTALE"
	echo "Total Users Processed: $TOTALG"
	echo "--------------------------"
	if [ $TOTALE -gt 0 ]; then
		exit 2;
	else
		exit 0;
	fi
}

# The game...
if [ $# -ne 1 ]; then
	dohelp;
	exit 1;
fi


case "$1" in
	-h) dohelp 
	;;
	-c) docreate "-c" 
	;;
	-v) docreate "-v"
	;;
	*) dohelp; exit 1
	;;
esac
