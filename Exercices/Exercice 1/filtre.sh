#!/bin/sh

# filtre - A script to return the list of abusive users.

EXEC_PATH="`dirname \"$0\"`"
HELP='usage: filtre path domain [-v]'

##### Functions

function verbose_log (){
  if [ "$VERBOSE" == "1" ]; then
    echo $1
  fi
}

function verify_datapath_exists (){
  if ! [ -d $1 ]; then
    echo "Datapath doesn't exist!"
    exit 1
  fi
}


function validate_data_file (){
  while read line
  do
    verifyEmailRegex $line $1
  done < $1
}

function verifyEmailRegex (){
  if [ "$1" == ?*@?*.?* ]; then
    verbose_log "$1 in file $2 is not a valid email address"
    verbose_log "Filtre expects data files to be lists of email addresses"
    exit 1
  fi
}

function usernamesForDomain (){
  local FILES=$1/*
  for f in $FILES
  do
    if [ -d $f ]; then
      verbose_log "Processing folder $f"
      usernamesForDomain $f $2
    else
      verbose_log "Processing $f file..."
      validate_data_file $f
      verbose_log "Searching $f for @$2"
      for line in `grep "@$2" $f | cut -d '@' -f 1`
      do
        MATCHES="$MATCHES $line"
      done
    fi
  done
}

function sortAndRemoveDuplicates (){
  MATCHES=$(echo $MATCHES | xargs -n1 | sort -u | xargs)
  echo $MATCHES
}

##### Arguments & Data sanitizing

if [ $# -gt 2 ]; then
    if [ $# == 3 -a $3 == '-v' ]; then
      VERBOSE=1;
      echo "Searching for bad users with domain @$2 and data directory $1 in verbose mode"
    else
      echo "Your command line contains too many arguments."
      echo $HELP
      exit 1
    fi

elif [ $# == 2 ]; then
    echo "Searching for bad users with domain @$2 and data directory $1"
else
    echo "Your command line contains not enough arguments"
    echo $HELP
    exit 1
fi

DATA_PATH="$EXEC_PATH/$1"
verify_datapath_exists $DATA_PATH
usernamesForDomain $DATA_PATH $2
sortAndRemoveDuplicates $MATCHES
