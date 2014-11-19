#!/bin/bash

BIN=/home/kvm/bin

for STOPPED in `$BIN/running.sh | grep stopped | awk '{print $1}'`
do
	. /home/kvm/conf/$STOPPED.conf

	if $BIN/ip link show $IFNAME &> /dev/null 
	then
		$BIN/tunctl -d $IFNAME
	fi	
done
