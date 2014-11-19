#!/bin/bash

#HOSTIP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | sed -e 's/addr://'`

#echo $HOSTIP

IFSPEED="100mbit"
VESPEED="5mbit"
VECEIL="50mbit"
SPEEDLIMIT="1mbit"

SHAPEIPS=`echo 208.64.38.{101..126}`
LIMITIP="208.64.38.112"

addtc()
{
        tc qdisc del dev $DEV root

        tc qdisc add dev $DEV root handle 1: htb

        tc class add dev $DEV parent 1: classid 1:1 htb rate "$VECEIL" burst 15k quantum 60000
	tc class add dev $DEV parent 1:1 classid 1:10 htb rate "$VESPEED" ceil "$VECEIL" quantum 3000 
	
	tc class add dev $DEV parent 1:1 classid 1:20 htb rate "$SPEEDLIMIT" quantum 3000
	tc class add dev $DEV parent 1:20 classid 1:21 htb rate 500kbit ceil "$SPEEDLIMIT" prio 0
	tc class add dev $DEV parent 1:20 classid 1:22 htb rate 500kbit ceil "$SPEEDLIMIT" prio 1
	
        tc qdisc add dev $DEV parent 1:10 handle 10: sfq perturb 10
	#tc qdisc add dev $DEV parent 1:21 handle 21: sfq perturb 10
	#tc qdisc add dev $DEV parent 1:22 handle 22: sfq perturb 10
	
	for IP in $SHAPEIPS
        do
		if [ "$IP" == "$LIMITIP" ]
		then
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 0x0 0xfc00 flowid 1:21
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 0x0 0xfc00 flowid 1:21
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 2222 0xffff flowid 1:21
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 2222 0xffff flowid 1:21
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:22
		else
		
                	tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:10
        	fi
	done

}

showtc()
{
        echo
        echo "tc configuration for $DEV:"
        tc qdisc show dev $DEV
        tc class show dev $DEV
        tc filter show dev $DEV
}




DEV="eth0"

addtc src
showtc


DEV="venet0"

addtc dst
showtc
