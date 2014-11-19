#!/bin/bash

ZMCTL=$1

ZMHOST=$2

if [ $# != 2 ]
then
	echo error: two arguments expected
	echo usage: zimbractl.sh command hostname
	exit 1
fi

ZMCHECK=""

zimbractl()
{

	ZMCMD=(vzctl exec $1 /root/zimbractl.sh $2)

        ${ZMCMD[@]}

        if [ $? == 0 ]
        then
                echo zimbra $2ed successfully

        else
                echo error encountered $2ing zimbra
        fi
}

zimbracheck()
{
	ZMCHECK=`vzlist -H | grep $ZMHOST | awk '{print $1}'`

	if [ -n "$ZMCHECK" ]
	then
        	return 0	
	else
        	return 1
	fi

}

zimbracheck
if [ $? == 0 ]
then
	echo zimbra found
	if [ "$ZMCTL" == "stop" ]
	then
		zimbractl "$ZMCHECK" "stop"
	elif [ "$ZMCTL" == "start" ]
	then
		zimbractl "$ZMCHECK" "start"
	else
		echo invalid command given, expected stop or start
	fi	
	
	if [ $? == 0 ]
	then
		echo command completed successfully
		exit 0
	else
		echo command completed with errors
		exit 1	
	fi
else
	echo zimbra at $2 not found
	exit 1
fi
