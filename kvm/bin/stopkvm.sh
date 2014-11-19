#!/bin/bash

HOME="/home/kvm"
ISO="$HOME/iso"
BIN="$HOME/bin"
MON="$HOME/mon"
CONF="$HOME/conf"

if [ $# = 1 ] || [ $# = 2 ]
then 
	CFGFILE="$CONF/$1.conf"

	if [ -a $CFGFILE ]
	then
		. $CFGFILE
	else
		echo $CFGFILE does not exist 
		exit 1
	fi	
	
	if [ $# = 1 ]
	then
		echo "system_powerdown" | /usr/bin/socat - UNIX-CONNECT:$MONITOR
	elif [ $# = 2 ] && [ $2 == "quit" ]
	then
		echo "quit" | /usr/bin/socat - UNIX-CONNECT:$MONITOR
	else
		echo invalid second argument
	fi
else
	echo must specify an instance name
	exit 1
fi
