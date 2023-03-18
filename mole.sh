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

function testFunction (){
	t=$1
   	echo "fresh(): \$1 is $t"
}


##### MOLE_RC CONDITION CHECK #####

if [ -z $MOLE_RC ]; then
	echo "MOLE_RC neexistuje" >&2
	exit 2
fi

if [ ! -f $MOLE_RC ]; then
		eval touch $MOLE_RC		
		echo "MOLE_RC byl vytvoren"
fi 


##### MAIN #####


eval lastArg='$'$#

filePath=$PWD


gWasCalled=false
mWasCalled=false



#if lastArg is a file. User want to edit file or (and) to add to a group. 
if [ -f $lastArg ] && [ "$#" != "0" ]; then #check if lastArg is a file.
	if [ "$#" != "0" ]; then #check if lastArg is not a script name.
		while getopts :g: OPTION; 
		do	case "$OPTION" in
		
    		g) 
      	 		gWasCalled=true
				
			if [ "$lastArg" = "$OPTARG" ]; then #if group was selected
	 			echo "You used '-g', but didn't select the group you want to add the file to" >&2 
				exit 2 
			fi

	 		eval echo "$lastArg,$PWD,$(date +%Y-%m-%d),$OPTARG" >>$MOLE_RC #write file_name,path,date,group to $MOLE_RC 
	 		openEditor 
	 		;;    
		esac
		done
		
		if [ "$gWasCalled" = false ]; then #if -g key wasn't used
			openEditor
		fi

	fi
else


eval grep -r "$PWD" $MOLE_RC


#while getopts :hg:m OPTION; 
#do	case "$OPTION" in
#	h)
#	 echo "
#		mole -h
#		mole [-g GROUP] FILE
#		mole [-m] [FILTERS] [DIRECTORY]
#		mole list [FILTERS] [DIRECTORY]" ;;
#    	g) 
#      	 #gWasCalled=true
#		#if [ -f $lastArg ]; then
#
#			#if [ "$lastArg" = "$OPTARG" ]; then
	 		#	echo "You used '-g', but didn't select the group you want to add the file to" >&2 
			#	exit 2 
			#fi

	 		#eval echo "$lastArg,$PWD,$(date +%Y-%m-%d),$OPTARG" >>$MOLE_RC 
	 		#echo "Option g used"
	 		#openEditor
#			
#		#else 
#			echo "You used '-g', but didn't chose a file."
#		#fi 
#	 		;;    	
 #   	m)
#	 mWasCalled=true
#      	 echo "Option c used" ;;	
#
#	?)
#	 printf "Usage: %s: [-h] [-m] [-g GROUP] args\n" $0 
#      	 ;;
#      esac
#   done

testFunction 1 2 3


#if [ ! -f $lastArg ]; then
#
#fi



#shift $OPTIND

#echo "Remaining arguments: '$*'"

fi
