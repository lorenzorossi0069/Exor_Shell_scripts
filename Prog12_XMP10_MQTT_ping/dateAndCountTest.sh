#!/bin/sh
echo "log of $0" > logfile.log
count=0

while true ; do
	count=$(($count+1))
	
	dateOld=$(date +%s)
	sleep 1 	
	dateNew=$(date +%s)
	delta=$(( $dateNew-$dateOld ))
	echo "delta = $delta sec; count = $count" 
	echo "delta = $delta sec; count = $count" >> logfile.log
	dateOld=dateNew
done