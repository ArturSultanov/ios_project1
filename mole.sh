#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

##### FUNCTIONS #####

openEditor () { #Open file using EDITOR, VISUAL or vi.
	if [ -f $1 ]; then	
		if [ -z  $EDITOR ]; then
			if [ -z $VISUAL ]; then	
				eval 'vi' "$1"
			else
				eval '$VISUAL' "$1"
			fi
		else
			eval '$EDITOR' "$1"
		fi
	else
		echo "$1 is not a file. Cant open editor" >&2
	fi		
}

function testFunction (){
	t=$1
   	echo "fresh(): \$1 is $t"
}


##### MOLE_RC CONDITION CHECK #####

if [ -z $MOLE_RC ]; then
	echo "MOLE_RC neexistuje" >&2
	exit 2
elif ! [ -f $MOLE_RC ]; then
	mkdir -p "$(dirname "$MOLE_RC")" && touch "$MOLE_RC"
	echo "MOLE_RC byl vytvoren"
fi


##### MAIN #####

eval lastArg='$'$#
directory="$PWD"	#[DIRECTORY]


#if lastArg is a file. User want to edit file or (and) to add to a group. 

if [ -f $lastArg ] && [ "$#" != "0" ]; then #check if lastArg is a file.
	if [ "$#" != "0" ]; then #check if lastArg is not a script name.
		filePath="$directory/$lastArg"	
	
		gWasCalled=false
		while getopts :g: OPTION; 
		do	case "$OPTION" in
		
    		g) 
      	 		gWasCalled=true
				
			if [ "$lastArg" = "$OPTARG" ]; then #if group was selected
	 			echo "You used '-g', but didn't select the group you want to add the file to" >&2 
				exit 2 
			fi

	 		eval echo "$lastArg,$PWD,$(date +%Y-%m-%d),$OPTARG" >>$MOLE_RC #write file_name,path,date,group to $MOLE_RC 
	 		openEditor "$filePath" 
	 		;;    
		esac
		done
		
		if [ "$gWasCalled" = false ]; then #if -g key wasn't used
			openEditor "$filePath"
		fi

	fi
#elif second arg. is list
elif [ "$2" = "list" ]; then
echo "list"


#else user can call another -keys to check changed file in directories
else

groupFilter=""		#-g
mostFrequent=false	#-m
dateAfter=""		#-a
dateIgnored=""		#-b


fResult=""

#Check if DIRECTORY was set by user. 
if [ -d $lastArg ] && [ "$#" != "0" ]; then 
	directory=$lastArg
	
fi

#Check optional flags
while getopts "hmg:a:b:" opt; do
    case $opt in
	h)
	   echo "mole -h\n
		mole [-g GROUP] FILE\n
		mole [-m] [FILTERS] [DIRECTORY]\n
		mole list [FILTERS] [DIRECTORY]\n
		mole secret-log [-b DATE] [-a DATE] [DIRECTORY1 [DIRECTORY2 [...]]]"
	;;	

        m)
            	mostFrequent=true
	;;
	g)
		groupFilter="$OPTARG"
        ;;
	a)
		dateAfter="$OPTARG"
	;;
        b)
            	dateIgnored="$OPTARG"
        ;;
        \?)
            	echo "Wrong flag: -$OPTARG" >&2
            	exit 1
       	;;
    esac
done

shift $((OPTIND-1))

if [ "$#" != 0 ]; then
	if [ "$1" != "$directory" ]; then
		echo "You used unavalible argument" >&2
		exit 1
	fi

fi
fResult=$(grep -r "$directory" "$MOLE_RC")

#Group filter 
if ! [ -z "$groupFilter" ] && ! [ -d "$groupFilter" ]; then
	groupFilter=$(echo $groupFilter | sed 's/,/|/g')
	fResult=$(echo "$fResult" | grep -E "$groupFilter")
fi

#Date ignored
if ! [ -z "$dateIgnored" ] && ! [ -d "$dateIgnored" ]; then
	fResult=$(echo "$fResult" | awk -v ignored="$dateIgnored" '{ if ($0 !~ ignored) print }')
fi 

#Date after
if ! [ -z "$dateAfter" ] && ! [ -d "$dateAfter" ]; then
	fResult=$(echo "$fResult" | awk -v d="$dateAfter" -F',' '{if ($3 >= d) print $0}')
fi

#The most frequent file
if [ "$mostFrequent" = "true" ]; then
	fResult=$(echo "$fResult" | awk -F',' '{print $1}' | sort | uniq -c | awk '{print $2}') #Sort result to most frequent file name. Leave only file names
else
	fResult=$(echo "$fResult" | awk -F',' '{print $1}')	#Leave only file names
fi

#call openEditor(filePath)
if [ "$fResult" = "\n" ] || [ "$fResult" = " " ] || [ "$fResult" = "" ]; then
	echo "No file to open" >&2
else
	
	for file in $fResult; do
		if [ -f "$directory/$file" ]; then
		openEditor "$directory/$file"
		break
		fi
	done
fi	

#########################DONT DELETE#########################
fi
