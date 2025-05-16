#!/bin/sh

# check if file exists
if [ ! -f $1 ]; then
  echo file $1 not found
  exit 1
fi

# check if file has read permission
if [ ! -r $1 ]; then
	echo file $1 cannot be read
	exit 1
fi

#count line number of command source file
linecount=0

#duplicate fd0 (stdin) into fd3 to get enter key  
exec 3<&0

# read -r : -r	do not allow backslash to escape any characters
#while IFS='' read -r line || [ -n $line ] ; do
while IFS='' read -r line  ; do
	(( linecount=linecount+1 ))
	#if [[ -n $line ]] && [[ ! $line==#* ]] ; then
	if [[ -n $line ]] && [[ ! $line == '#'* ]] ; then
		echo '(' $linecount '):' $line
		#--- execute commanad ---
		#$(sudo ./$line) 
		sudo ./$line 
		#sudo sh -c "./$line"
		#------------------------
		echo "press enter to continue (or Ctrl-C to quit)"
		read -r -u3 val #read val from fd3
	fi
done < $1  #bound input to file specified in $1

