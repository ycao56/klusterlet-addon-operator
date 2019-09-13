#!/bin/bash

# PARAMETERS
# $1 - command: use 'fix' for fix, otherwise a check is run

if [ "fix" == "$1" ]; then
  DO_COPYRIGHT_FIX=1
fi

HEADER_REGEXPS=( \
'IBM Confidential' \
'OCO Source Materials' \
'5737-E67' \
'\(C\) Copyright IBM Corporation [0-9]{4}(, [0-9]{4})? All Rights Reserved' \
'The source code for this program is not published or otherwise divested of its trade secrets, irrespective of what has been deposited with the U.S. Copyright Office\.' \
)

# Used to signal an exit
ERROR=0

# Scan the files
for f in `find . -type f -iname "*.go" ! -iname ".*" ! -path "*/.*" ! -path "./internal/mocks/*" ! -path "./test/*" ! -path "./vendor/*"`; do
  if [ ! -f "$f" ]; then
    continue
  fi

  #Read the first 10 lines, most Copyright headers use the first 6 lines.
  HEADER=`head -6 $f`

  #Check for all copyright lines
  for i in "${HEADER_REGEXPS[@]}"; do
    #Validate the copyright line being checked is present
    __pattern="${i/ /[[:space:]]}"
    if [[ ! "$HEADER" =~ $__pattern ]]; then
      if [ $DO_COPYRIGHT_FIX ]; then
        cat build/copyright-go.txt $f > $f.bak
        mv -f $f.bak $f
        printf "  >>Fixed copyright in file $f\n"
        break
      else
        echo -e "not ok\t\t$f\t\t'$i' not found"
        ERROR=1
        break
      fi
    fi
  done
done

exit $ERROR
