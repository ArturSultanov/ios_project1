#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

##### FUNCTIONS #####

function openEditor () { #Open file using EDITOR, VISUAL or vi.
	if [ -f $lastArg ]; then	
		if [ -z  $EDITOR ]; then
			if [ -z $VISUAL ]; then	
				eval 'vi'  $lastArg
			else
				eval '$VISUAL' $lastArg
			fi
		else
			eval '$EDITOR' $lastArg
		fi
	fi		
}

##### CONDITION CHECK #####

if [ -z $MOLE_RC ]; then
	echo "MOLE_RC neexistuje" >&2
	exit 2
fi

if [ ! -f $MOLE_RC ]; then
		touch "$MOLE_RC"
		echo "MOLE_RC byl vytvoren"
fi 


if [ $# -eq 0 ]; then
	echo "You didn't enter any argument" >&2
	echo "Use '-h' to get help"
fi

##### MAIN #####


eval lastArg='$'$#

gWasCalled=false
mWasCalled=false


while getopts :h OPTION;
do	case "$OPTION" in
	h)
	 	 echo "
			mole -h
			mole [-g GROUP] FILE
			mole [-m] [FILTERS] [DIRECTORY]
			mole list [FILTERS] [DIRECTORY]" ;;
 esac
done




	while getopts :g:m OPTION; 
	do	case "$OPTION" in
		    		g) 
      	 	gWasCalled=true
			if [ -f $lastArg ]; then

			if [ "$lastArg" = "$OPTARG" ]; then
	 			echo "You used '-g', but didn't select the group you want to add the file to" >&2 
				exit 2 
			fi

	 		eval echo "$lastArg,$PWD,$(date +%Y-%m-%d),$OPTARG" >>$MOLE_RC 
	 		echo "Option g used"
	 		openEditor
		else 
			echo "You used '-g', but didn't chose a file."
		fi 
	 		;;    	

    		m)
	 	mWasCalled=true
      	 	echo "Option c used" ;;	

		?)
	 	printf "Usage: %s: [-h] [-m] [-g GROUP] args\n" $0 
      	 	;;
      	 esac
   	done

#if [ "$gWasCalled" = false ]; then
#	openEditor
#fi

#shift $OPTIND
#echo "Remaining arguments: '$*'"
