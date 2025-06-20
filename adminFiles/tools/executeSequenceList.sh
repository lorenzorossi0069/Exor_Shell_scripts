#!/bin/sh

#Execute sequence of commands read from a file
# with: #=skip line; @=breakpoint
#if arg $2 is 's' (step) then do step by step whole seq

# check if sequence file exists
#if [[ ! -f $1 ]] || [[ $1 == '' ]] ; then
if (($# < 1)) ; then
  echo "sequence file (arg1) not found"
  echo "$0 <seqFile> [s (=step by step mode)]"
  exit 1
else
	echo "type $0 <seqFile> s for step by step mode"
fi

stepOnFlag=$2

# check if sequence file has read permission
if [[ ! -r $1 ]]; then
	echo "sequence file $1 has not read permission"
	exit 1
fi

#===add current path ===
PATH=$PATH:$(pwd)


trap terminateEmission SIGINT

echo

#duplicate fd0 (stdin) into fd3 to get enter key  
exec 3<&0

# read -r : -r	do not allow backslash to escape any characters
#while IFS='' read -r line || [[ -n $line ]] ; do
while IFS='' read -r line  ; do
	if [[ -n $line ]] && [[ ! $line == '#'* ]] ; then
		if [[ $line == '@'* ]]  ; then
            echo -n "${line:1}  "
			echo "  (press enter to execute)"
			read -r -u3 val     #read val from fd3
			${line:1}
		else
			echo -n "$line  "
			
			if [[ $stepOnFlag == 's' ]] ; then
				echo "  (press enter to execute, \'c\' to skip all breakpoints )"
				read -r -u3 val     #read val from fd3
				if [[ $val == 'c' ]] ; then
					stepOnFlag=''
				fi
			fi
		   
			$line
			sleep 0.1 
		fi
		echo 
	fi
done < $1  #bound input to file specified in $1


