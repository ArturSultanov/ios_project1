#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8
#export MOLE_RC=/Users/artur.sultanov/vut/ios/molerc/molerc.txt

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

#Group filter 
if ! [ -z "$groupFilter" ] && ! [ -d "$groupFilter" ]; then
	groupFilter=$(echo "$groupFilter" | sed 's/,/|/g')
	fResult=$(echo "$fResult" | grep -E "$groupFilter")
fi

#Date ignored
if ! [ -z "$dateIgnored" ] && ! [ -d "$dateIgnored" ] && ! [ -f "$dateAfter" ]; then
	fResult=$(echo "$fResult" | awk -v ignored="$dateIgnored" '{ if ($0 !~ ignored) print }')
fi 

#Date after
if ! [ -z "$dateAfter" ] && ! [ -d "$dateAfter" ] && ! [ -f "$dateAfter" ]; then
	fResult=$(echo "$fResult" | awk -v d="$dateAfter" -F',' '{if ($3 >= d) print $0}')
fi

#Realization of calling "mole list [FILTERS] [DIRECTORY]"##################
if [ "$listSecond" = true ]; then
	#!/bin/sh


#!/bin/sh

IFS='
'

if [ -z "$fResult" ]; then
    output="Нет файлов в заданной директории."
else
    # Получение самого длинного имени файла
    max_length=0
    for line in $fResult; do
        file_name=$(echo "$line" | cut -d',' -f1)
        if [ ${#file_name} -gt $max_length ]; then
            max_length=${#file_name}
        fi
    done

    output=""
    unique_files=$(echo "$fResult" | cut -d',' -f1 | sort | uniq)
    for file_name in $unique_files; do
        groups=""
        for line in $fResult; do
            current_file_name=$(echo "$line" | cut -d',' -f1)
            if [ "$file_name" = "$current_file_name" ]; then
                current_group=$(echo "$line" | cut -d',' -f4)
                if [ -n "$groups" ]; then
                    groups="$groups,$current_group"
                else
                    groups="$current_group"
                fi
            fi
        done
        if [ -z "$groups" ]; then
            groups="-"
        fi
        output="$output$(printf "%s:%*s%s\n" "$file_name" $((max_length - ${#file_name} + 1)) " " "$groups")"
    done
fi

echo "$output"


else

#Realization of calling "mole [-m] [FILTERS] [DIRECTORY]"##################

#Save only file path
#Last edit file is first 
fResult=$(echo "$fResult" | awk -F',' '{print $2}'  | tail -r)

#The most frequent file
if [ "$mostFrequent" = "true" ]; then
	#Sort result to most frequent file
	fResult=$(echo "$fResult" | sort | uniq -c | sort -nr| awk '{print $2}')
fi

#filter of deleted files
fResultFiltered=$(echo "$fResult" | grep -xE '.*' | 
			while read line; do 
			[ -f "$line" ] && echo "$line"; 
			done)

#use openEditor to filtered file
if [ "$listSecond" = false ]; then
first_line=$(echo "$fResultFiltered" | head -n 1)
openEditor "$first_line"
fi

fi
#########################DONT DELETE#########################
fi
