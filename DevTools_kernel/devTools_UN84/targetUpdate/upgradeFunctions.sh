#!/bin/sh

function updateFileAndSaveOld {
	local saveOldFlag=$1
	local sourcePath=$2
	local destPath=$3
	local fileName=$4
	
	local NO_BKP=0
	local DO_BKP=1
	
	#INFO: check if source file exists
	if [[ ! -e $sourcePath/$fileName ]] ; then
		echo
		echo "file $sourcePath/$fileName not found"
		echo "=============="
		echo "PROGRAM FAILED"
		echo "=============="
		exit 1
	fi
	
	#INFO: check if file is already existing
	if [[ -e $destPath/$fileName ]] ; then
	
		#INFO: if file exists, and differs, save a backup copy
		if [[ $(diff ./$fileName $destPath/$fileName) ]] ; then
			if [[ $saveOldFlag == $DO_BKP ]] ; then
				bkpFileName=${fileName}_$(date "+%d-%m-%C%y_h%H-%M-%S.ko")
				cp ${destPath}/${fileName} ${destPath}/$bkpFileName
				echo "$fileName is changed. Old is saved as ${destPath}/$bkpFileName"	
			else
				echo "$fileName is overwritten (no backup)"
			fi
			
			
		else
			echo "$fileName is not changed"
		fi
	fi

	cp $sourcePath/$fileName   $destPath/$fileName
}

function copyFileToTaget {
	local sourcePath=$1
	local sourceFileneme=$2
	local targetPath=$3
	local targetFileName=$4
		
	#INFO: check if source file exists
	if [[ ! -e $sourcePath/$sourceFileneme ]] ; then
		echo
		echo "file $sourcePath/$sourceFileneme not found"
		echo "=============="
		echo "PROGRAM FAILED"
		echo "=============="
		exit 1
	fi
	
	cp $sourcePath/$sourceFileneme   $targetPath/$targetFileName
}

#--------------------------------------
function createUnexistingFolder {
        local newFolder=$1
        if [[ ! -d $newFolder ]] ; then
                echo "creating $newFolder"
                mkdir $newFolder
        else
                echo "folder already found: $newFolder"
        fi
}

#--------------------------------------
function OLD_rename_modules_folder {

	if [[ $# < 1 ]] ; then
			echo "Error: arguments must be: <4.14./5.10.>"
			echo "---------------------------------------"
			exit 1
	fi
	
	local ref_name=$1
	if [[ $ref_name != 5.10. ]] && [[ $ref_name != 4.14. ]] ; then
			echo "unknown branch, exiting"
			echo "-----------------------"
			exit 1
	fi
	
	TARGETDIR=/lib/modules
	cd $TARGETDIR

	if  (( $(ls | wc -l) != 1 )) ; then
		#this handles anomalous case, where more folders are found
		echo "found more candidate folders in $TARGETDIR:"
		ls -l
		
		closest_name=$(ls | grep "^$ref_name" | sort | head -n 1)
		echo "most probable name is $closest_name"
		
		fileNameIsOk=""
		echo -n "press y to use $closest_name, else any other key to exit and clean $TARGETDIR "; 
		read fileNameIsOk
		if [[ $fileNameIsOk != "y" ]] ; then
			echo "failed renaming as $(uname -r) (in $TARGETDIR)"
			echo "----------------------------------------------"
			exit 1
		fi	
		oldName=$closest_name
	else
		#this handles expected case, where just one folders is found (as should be)
		oldName=$(ls)
	fi

	newname=$(uname -r)

	if [[ $oldName == $newname ]] ; then
		echo "folder name is already $oldName"
	else
		echo "renaming $oldName --> $newname"
		mount -o remount,rw /
		mv $TARGETDIR/$oldName $TARGETDIR/$newname
	fi
}


function rename_modules_folder {
	argK=$1
	
	if [[ $argK == K5 ]] ; then
		ref_name="5.10."
	elif [[ $argK == K4 ]] ; then
		ref_name="4.14."
	else
		echo "Error: argument must be: <K4/K5>"
			echo "---------------------------------------"
			exit 1
	fi
	

	TARGETDIR=/lib/modules
	cd $TARGETDIR

	if  (( $(ls | wc -l) != 1 )) ; then
		#this handles anomalous case, where more folders are found
		echo "found more candidate folders in $TARGETDIR:"
		ls -l
		
		closest_name=$(ls | grep "^$ref_name" | sort | head -n 1)
		echo "most probable name is $closest_name"
		
		fileNameIsOk=""
		echo -n "press y to use $closest_name, else any other key to exit and clean $TARGETDIR "; 
		read fileNameIsOk
		if [[ $fileNameIsOk != "y" ]] ; then
			echo "failed renaming as $(uname -r) (in $TARGETDIR)"
			echo "----------------------------------------------"
			exit 1
		fi	
		oldName=$closest_name
	else
		#this handles expected case, where just one folders is found (as should be)
		oldName=$(ls)
	fi

	newname=$(uname -r)

	if [[ $oldName == $newname ]] ; then
		echo "folder name is already $oldName"
	else
		echo "renaming $oldName --> $newname"
		mount -o remount,rw /
		mv $TARGETDIR/$oldName $TARGETDIR/$newname
	fi
}
