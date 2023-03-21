#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

##### FUNCTIONS #####

openEditor () { #Open file using EDITOR, VISUAL or vi.
	if [ -f "$1" ]; then	
		if [ -z  "$EDITOR" ]; then
			if [ -z "$VISUAL" ]; then	
				vi "$1"
			else
				eval '$VISUAL' "$1"
			fi
		else
			eval '$EDITOR' "$1"
		fi
		exit
	else
		echo "$1 is not a file. Cant open editor" >&2
		exit 1
	fi		
}

function testFunction (){
	t=$1
   	echo "fresh(): \$1 is $t"
}


##### MOLE_RC CONDITION CHECK #####

if [ -z "$MOLE_RC" ]; then
	echo "MOLE_RC neexistuje" >&2
	exit 2
elif ! [ -f "$MOLE_RC" ]; then
	mkdir -p "$(dirname "$MOLE_RC")" && touch "$MOLE_RC"
	echo "MOLE_RC byl vytvoren"
fi


###################### MAIN ######################################

eval lastArg='$'$#
directory="$PWD"	#[DIRECTORY]

groupFilter=""		# -g
mostFrequent=false	# -m
dateAfter=""		# -a
dateIgnored=""		# -b
listSecond=false	# list
gWasCalled=false

while getopts "hmg:a:b:" opt; do
    case $opt in
	h)
	   echo "mole -h
mole [-g GROUP] FILE
mole [-m] [FILTERS] [DIRECTORY]
mole list [FILTERS] [DIRECTORY]"
	   exit
	;;	

        m)
            	mostFrequent=true
	;;
	g)
		groupFilter="$OPTARG"
		gWasCalled=true
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

#Check if DIRECTORY was set by user. 
if [ -d "$lastArg" ] && [ "$#" != "0" ]; then 
	directory=$lastArg
	
fi

#Check is second argument is "list"
if [ "$1" = "list" ]; then
	listSecond=true
	shift
fi

shift $((OPTIND-1))

#Realization of calling "mole [-g GROUP] FILE"############################# 
if [ -f $1 ] && [ "$#" != "0" ]; then #check if lastArg is a file.	
      	if [ "$gWasCalled" = true ];then
			
			fileDir=$(dirname "$1")
			if ! [ -d fileDir ]; then
				fileDir=$PWD
			fi 
			fileName="$(echo "$1" | awk -F'/' '{print $NF}')"
	 		echo "$fileName,$fileDir/$fileName,$(date +%Y-%m-%d),$groupFilter" >>$MOLE_RC #write file_path,date,group to $MOLE_RC 
	 		openEditor "$fileDir/$fileName" 
		
		elif [ "$gWasCalled" = false ]; then #if -g key wasn't used
			openEditor "$fileDir/$fileName" 
		fi


#Realization of calling "mole list [FILTERS] [DIRECTORY]"##################
elif [ "$listSecond" = true ]; then
echo "list"


#Realization of calling "mole [-m] [FILTERS] [DIRECTORY]"##################
else

fResult=""

#Check optional flags
#Check if user used unavalible argument
if [ "$#" != 0 ]; then
	if [ "$1" != "$directory" ]; then
		echo "You used unavalible argument" >&2
		exit 1
	fi
fi

fResult=$(grep -r "$directory" "$MOLE_RC")

echo "$fResult"
#Group filter 
if ! [ -z "$groupFilter" ] && ! [ -d "$groupFilter" ]; then
	groupFilter=$(echo "$groupFilter" | sed 's/,/|/g')
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

#Save only file path
#fResult=$(echo "$fResult" | awk -F',' '{print $3"/"$2}' | tail -r)

fResult=$(echo "$fResult" | awk -F',' '{print $2}'  | tail -r)

#The most frequent file
if [ "$mostFrequent" = "true" ]; then
	#Sort result to most frequent file
	fResult=$(echo "$fResult" | sort | uniq -c | sort -nr| awk '{print $2}')
fi
echo "###"
echo "$fResult"

first_line=$(echo "$fResult" | head -n 1)
'vim' "$first_line"
#
#########################DONT DELETE#########################
fi
