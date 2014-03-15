#!/bin/sh

# filtre - A script to return the list of abusive users.

EXEC_PATH="`dirname \"$0\"`"
HELP='usage: protege path [users ...]'
FN='.htaccess' #filename

##### Functions

function verify_datapath_exists (){
  if ! [ -d $1 ]; then
    echo "Folder to protect doesn't exist!"
    exit 1
  fi
}

# Adds correct permission to the folder
# If no .htaccess is found, the file is created.
# If .htaccess exists, we first verify if the permission is already present.

function addPermission (){
  echo $1/$FN
  if ! [ -f $1/$FN ]; then
    touch $1/$FN
  fi

  for var in "${@:2}"
  do
    echo "Adding user : $var"
    local USERCONFIG="Require user $var"

    if ! grep --quiet "$USERCONFIG" $1/$FN; then
      echo User not found
      echo $USERCONFIG >> $1/$FN
    fi
  done

  for directory in $(find $1 -mindepth 1 -maxdepth 1 -type d) ; do
    addPermission $directory ${@:2}
  done
}

##### Arguments

if [ $# -lt 2 ]; then
  echo "Your command line contains not enough arguments"
  echo $HELP
  exit 1
fi

verify_datapath_exists $1
addPermission $EXEC_PATH/$1 ${@:2}
