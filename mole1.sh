#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

if [ -z "$1" ];then	#if there is no argument
	echo "Empty list of options" >&2
    exit 1
fi

if [ -z $EDITOR ] ;
  then echo "EDITOR neni nastaven"
  if [ -z $VISUAL ]
    then echo "VISUAL neni nastaven. By default: vi"

    echo "$EDITOR"
  else
    echo "Editor: $VISUAL"
  fi
else
  echo "Editor: $EDITOR"
fi

dir=
fname=

if [ -z $MOLE_RC ] ;
  then echo "MOLE_RC was not set up\n">&2
  exit
else
  FILE=$MOLE_RC
  dir="${MOLE_RC%/*}/"
  fname=${MOLE_RC##*/}
  echo $dir
  echo $fname
  if ! [ -d $dir ]; then
    echo 'No directory'
    mkdir "$dir"
  fi
  if test -f "$FILE"; then
      echo "$FILE exists.\n"
  else
    echo "$FILE does not exists"
    touch $MOLE_RC
  fi
fi


help()
{       echo "HelloW"
}

isAppointed=false
mostOpened=false
soubor=
while getopts "hg::m" arg; do
        case "$arg" in
                h)
                  help
                  exit 1
                  ;;

                g)
                  isAppointed=true

                  ;;
                m)
                  mostOpened=true
                  ;;
                *)
                  ;;
        esac
        shift
done

if [ "$isAppointed" = true ]; then
  printf "$groups"
fi

#zpracovani souboru
shift $((OPTIND))
if [ "$#" = 0 ]; then
        echo "Chyba: chybi soubor FILE"
        help
else
        soubor="$1"
fi

if [ "$soubor" ]; then
  cat "$soubor"
else
        echo "Chyba: soubor neexistuje"
        help
fi

last_id=$#
last_element=${@:last_id}

