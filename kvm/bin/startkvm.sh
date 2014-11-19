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
else
	echo must specify an instance name
	exit 1
fi

$BIN/kvm-perms.sh $DISK

if [ $# = 2 ] && [ $2 = "noip" ]
then
	echo not adding an IP for guest
	$BIN/kvm-ifup.sh $IFNAME $TAPMAC noip
else
	$BIN/kvm-ifup.sh $IFNAME $TAPMAC $IP
fi

$BIN/kvm -m $MEM \
-drive file=$DISK,if=$DISKIF,boot=on,cache=none \
-serial none -parallel none \
-net nic,\
model=$NICMODEL,macaddr=$KVMMAC \
-net tap,ifname=$IFNAME,script=no \
-daemonize -vnc $VNC \
-boot $BOOT -cdrom $CD \
-monitor unix:$MONITOR,server,nowait \
-balloon none \
$OPTIONS
