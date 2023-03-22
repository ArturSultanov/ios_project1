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

		fileDir=$(dirname "$1")
		if ! [ -d fileDir ]; then
				fileDir=$PWD
		fi 
		fileName="$(echo "$1" | awk -F'/' '{print $NF}')"
		#write mole.sh,file_path,date,group to $MOLE_RC.
		#write "mole.sh" or "$0" because getting $1 column for from $MOLE_RC is not stable. 
		#$1 returns not only first column of the file string, but the path $MOLE_RC.
	 	echo "$0,$fileName,$fileDir/$fileName,$(date +%Y-%m-%d),$groupFilter" >>"$MOLE_RC" 
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
secretLog=false		# secret-log

#Check is first argument is "list"
if [ "$1" = "list" ]; then
	listSecond=true
	shift
fi

#Check is first argument is "secret-log"
if [ "$1" = "secret-log" ]; then
	secretLog=true
	shift
fi

#Check if DIRECTORY was set by user. 
if [ -d "$lastArg" ] && [ "$#" != "0" ]; then 
	directory=$lastArg
fi

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
	:)
    	echo "Требуется аргумент после параметра: -$OPTARG" >&2
        exit 1
    	;;
    esac
done

shift $((OPTIND-1))

#Realization of calling "mole [-g GROUP] FILE"############################# 
if [ -f "$1" ] && [ "$#" = "1" ]; then #check if lastArg is a file.	
	 		openEditor "$1" 

else

fResult=$(grep -r "$directory" "$MOLE_RC")

#Check if user used another avalible arguments
if [ "$#" -gt 0 ]; then
	if [ "$1" != "$directory" ] && [ "$secretLog" = false ]; then
		echo "You used unavalible argument" >&2
		exit 1
	elif [ "$secretLog" = true ]; then
		directory_list="$@"
	fi
fi

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
	fResult=$(echo "$fResult" | awk -v d="$dateAfter" -F',' '{if ($4 >= d) print $0}')
fi

#Realization of calling "mole list [FILTERS] [DIRECTORY]"##################
if [ "$listSecond" = true ]; then

# Инициализируем переменные для хранения результата и максимальной длины имени файла
listResult=""
max_file_len=0

# Получаем имена файлов из второй колонки и удаляем дубликаты
files=$(echo "$fResult" | awk -F',' '{print $2}' | sort -u)

# Итерируемся по каждому имени файла
for file in $files; do
  # Проверяем, что имя файла не является пустой строкой
  if [ -n "$file" ]; then
    # Извлекаем группы для данного файла

    #                                         |  get 5 column - group  |del. same gr.|    \n -> ,  | del , at the str. end
    groups=$(echo "$fResult" | grep ",$file," | awk -F',' '{print $5}' | sort | uniq | tr '\n' ',' | sed 's/,$//')

    # Если группы не найдены, то записываем "-"
    if [ -z "$groups" ]; then
      groups="-"
    fi
    
    # Обновляем максимальную длину имени файла, если текущая длина больше
    file_len=$(echo "$file" | wc -c)
    if [ "$file_len" -gt "$max_file_len" ]; then
      max_file_len="$file_len"
    fi
    
    # Добавляем имя файла и соответствующие ему группы в переменную result
    listResult="$listResult$file: $groups\n"
  fi
done

# Выводим результат, выравнивая группы по максимальной длине имени файла
#listResult=$(echo "$listResult" | grep -v '^$') #delete empty lines
echo "$listResult" | grep -v '^$'| awk -v max_file_len="$max_file_len" -F':' '{printf("%s:%"max_file_len-length($1)+2"s%s\n", $1, " ", $2)}'
exit

#Realization of calling "mole secret-log [-b DATE] [-a DATE] [DIRECTORY1 [DIRECTORY2 [...]]]"##################
elif [ "$secretLog" = true ]; then
echo "kek"

exit
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
