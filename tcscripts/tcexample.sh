#!/bin/bash

IFSPEED="100mbit"
SPEEDLIMIT="512kbit"

SHAPEIPS=`echo 192.168.1.{10..20}`
STARTSHAPECLASS=10

addtc()
{
        echo tc qdisc del dev $DEV root

        echo tc qdisc add dev $DEV root handle 1: htb

        echo tc class add dev $DEV parent 1: classid 1:1 htb rate "$IFSPEED" burst 15k quantum 60000
	
	SHAPECLASS=$STARTSHAPECLASS

        for IP in `echo "$SHAPEIPS"`
	do
        	echo tc class add dev $DEV parent 1:1 classid 1:"$SHAPECLASS" htb rate "$SPEEDLIMIT" quantum 3000
		SHAPECLASS=$(($SHAPECLASS+1)) 	
	done
	
	SHAPECLASS=$STARTSHAPECLASS
	
	for IP in `echo "$SHAPEIPS"`
        do
		echo tc filter add dev $DEV protocol ip parent 1:1 prio 1 u32 match ip $1 "$IP" flowid 1:"$SHAPECLASS"
		SHAPECLASS=$(($SHAPECLASS+1))
	done
		
}


DEV="eth0"

addtc src 

DEV="venet0"

addtc dst 
