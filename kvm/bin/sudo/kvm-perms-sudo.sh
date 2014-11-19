#!/bin/bash

if [ $# != 1 ]
then
	echo need at least one parameter
	exit 1
fi

kvmperms()
{
	KVMPERMS=`stat --format=%a $FILE`
	KVMGRP=`stat --format=%G $FILE`
	
	if [ $KVMPERMS != "660" ] || [ $KVMGRP != "kvm" ]
	then
        	chgrp kvm $FILE
        	chmod 660 $FILE
	fi
}

FILE=$1
kvmperms

FILE=/dev/kvm
kvmperms

FILE=/dev/net/tun
kvmperms
