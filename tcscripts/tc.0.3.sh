#!/bin/bash

#HOSTIP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | sed -e 's/addr://'`

#echo $HOSTIP

IFSPEED="25mbit"
VESPEED="1mbit"
VECEIL="24mbit"
SPEEDLIMIT="1mbit"

SHAPEIPS=`echo 208.64.38.{101..126}`
LIMITIP="208.64.38.112"

FIRSTCLASS="10"

addtc()
{
        tc qdisc del dev $DEV root

     	tc qdisc add dev $DEV root handle 1: htb r2q 16

      	tc class add dev $DEV parent 1: classid 1:1 htb rate "$IFSPEED" 
	#burst 15k quantum 60000
	
	CLASS="$FIRSTCLASS"	

	for IP in $SHAPEIPS
        do
		if `echo "$LIMITIP" | grep "$IP" > /dev/null`
                then
			tc class add dev $DEV parent 1:1 classid 1:"$CLASS" htb rate "$SPEEDLIMIT"
			#CLASS=$(($CLASS+1))
			tc class add dev $DEV parent 1:"$CLASS" classid 1:$(($CLASS+1)) htb rate 500kbit ceil "$SPEEDLIMIT" prio 0
			#CLASS=$(($CLASS+1))
			tc class add dev $DEV parent 1:"$CLASS" classid 1:$(($CLASS+2)) htb rate 500kbit ceil "$SPEEDLIMIT" prio 1
			CLASS=$(($CLASS+3))
		else
			tc class add dev $DEV parent 1:1 classid 1:"$CLASS" htb rate "$VESPEED" ceil "$VECEIL" 
#quantum 3000 
			tc qdisc add dev $DEV parent 1:"$CLASS" handle "$CLASS": sfq perturb 10
			CLASS=$(($CLASS+1))	
		fi
	done	
	
	CLASS="$FIRSTCLASS"
		
	for IP in $SHAPEIPS
        do
		if `echo "$LIMITIP" | grep "$IP" > /dev/null`
		then
			CLASS=$(($CLASS+1))
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 0x0 0xfc00 flowid 1:"$CLASS"
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 0x0 0xfc00 flowid 1:"$CLASS"
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 2222 0xffff flowid 1:"$CLASS"
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 2222 0xffff flowid 1:"$CLASS"
			CLASS=$(($CLASS+1))
			tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:"$CLASS"
			CLASS=$(($CLASS+1))
		else
		
                	tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:"$CLASS"
			CLASS=$(($CLASS+1))
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
