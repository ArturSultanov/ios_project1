#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

function check(){
	echo hi	
}

if [ -z $MOLE_RC ]; then
	echo "MOLE_RC neexistuje" >&2
	exit 1
fi

if [ ! -f $MOLE_RC ]; then
		touch "$MOLE_RC"
		echo "MOLE_RC byl vytvoren"
fi 

lastArg=

eval lastArg='$'$# 				#get last argument

#'vi' $lastArg

 

#Open file using EDITOR, VISUAL or vi
if [ $# ]; then				#check if user has typed any argumnts 
	if [ -f $lastArg ]; then	
	
		if [ -z  $EDITOR ]; then
			echo kek
			if [ -z $VISUAL ]; then
				'vi' $lastArg		#using vi as default option
			else
				eval '$VISUAL' $lastArg
			fi
		else
			eval '$EDITOR' $lastArg
		fi
	fi		
else 
	echo "Nezadal jste zadny argument"
fi




while getopts 'hg:a:b:' OPTION; do
	case "$OPTION" in
	h)
	 echo "
		mole -h
		mole [-g GROUP] FILE
		mole [-m] [FILTERS] [DIRECTORY]
		mole list [FILTERS] [DIRECTORY]" ;;
 
    	g) 
      	 echo "Option a used" ;;

    	b)
      	 echo "Option b used" ;;

    	c)
      	 echo "Option c used" ;;	

	?) 
      	 echo "WOW!"
      	 #exit 1
      	 ;;
      esac
   done
