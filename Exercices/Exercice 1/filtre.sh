#!/bin/sh

# filtre - A script to return the list of abusive users.
EXEC_PATH="`dirname \"$0\"`"
HELP='usage: filtre path domain'

##### Functions

function verify_datapath (){
  if ! [ -d $1 ]; then
    echo "Datapath doesn't exist!"
    exit 1
  fi
}

##### Arguments & Data sanitizing

if [ $# -gt 2 ]; then
    echo "Your command line contains too many arguments."
    echo $HELP
    exit 1
elif [ $# == 2 ]; then
    echo "Searching for bad users with domain @$2 and data directory $1"
    DATA_PATH="$EXEC_PATH/$1"
    verify_datapath $DATA_PATH
    find
else
    echo "Your command line contains not enough arguments"
    echo $HELP
    exit 1
fi
