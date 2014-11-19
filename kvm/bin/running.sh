#!/bin/bash

if [ $# = 0 ]
then

echo "KVM instance(s):"

for FILE in `ls /home/kvm/conf/*.conf`
do
	. $FILE
	
	#FILE=`basename $FILE`	
	#FILE=${FILE%%.*}
	PS=`ps x | grep kvm | grep $IFNAME | grep -v grep`
	if [ -n "$PS" ]
	then
		IP=`ip route | grep $IFNAME | awk '{print $1}'`
		PID=`echo $PS | awk '{print $1}'`
		INCOMING=`echo $PS | grep incoming`
		if [ -n "$INCOMING" ]
		then
			echo " $KVMID incoming $IFNAME $IP $PID $NAME $VNC"
		else
			echo " $KVMID running $IFNAME $IP $PID $NAME $VNC"
		fi
	else
		echo " $KVMID stopped $NAME"
	fi
done

elif [ $# = 1 ]
then
	
	RUNNING=`$0 | grep kvm$1 | grep -v stopped`
	if [ -n "$RUNNING" ]
	then
		echo running
		exit 0
	else
		echo not running
		exit 1
	fi 

fi
