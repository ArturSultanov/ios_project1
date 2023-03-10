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

while getopts :hg::m OPTION; 
do	case "$OPTION" in
	h)
	 echo "
		mole -h
		mole [-g GROUP] FILE
		mole [-m] [FILTERS] [DIRECTORY]
		mole list [FILTERS] [DIRECTORY]" ;;
 
    	g) 
      	 echo "Option a used" | openEditor;;    	

    	m)
      	 echo "Option c used" ;;	

	*) 
      	 ;;
      esac
   done

#shift $OPTIND
#echo "Remaining arguments: '$*'"
