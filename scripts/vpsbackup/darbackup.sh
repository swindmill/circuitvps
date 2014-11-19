#!/bin/bash

DATE=`date +%m.%d.%y`

DARPATH=/home/sterling/compiled/dar/bin/dar

INPUTDIR=/usbdrive/vzbackup/private

OUTPUTDIR=/usbdrive/darbackup

if [ -e $OUTPUTDIR/lastdate ]
then
	LASTDATE=`cat $OUTPUTDIR/lastdate`
fi

PASSPHRASE=b0ysc0ut

DARPARAMS="-K $PASSPHRASE -Z \"*.deb\" -Z \"*.Z\" -Z \"*.tgz\" -Z \"*.gz\" -Z \"*.bz2\" -Z \"*.zip\" -Z \"*.png\" -Z \"*.gif\" -Z \"*.rar\" -Z \"*.jpeg\" -Z \"*.jpg\" -Z \"*.jar\" -m 256 -z1 -w"

for DIR in `ls $INPUTDIR`
do

	if [ -e $OUTPUTDIR/$DIR.1.dar ]
	then
		if [ -e $OUTPUTDIR/${DIR}_$lastdate.1.dar ]
		then
	
			$DARPATH -c $OUTPUTDIR/${DIR}_$DATE -A $OUTPUTDIR/${DIR}_$LASTDATE -R $INPUTDIR/$DIR -J $PASSPHRASE $DARPARAMS
	
		else
		
			$DARPATH -c $OUTPUTDIR/${DIR}_$DATE -A $OUTPUTDIR/$DIR -R $INPUTDIR/$DIR -J $PASSPHRASE $DARPARAMS 

		fi
	
	else

		$DARPATH -c $OUTPUTDIR/$DIR -R $INPUTDIR/$DIR $DARPARAMS 
	fi

done

echo $DATE > $OUTPUTDIR/lastdate
