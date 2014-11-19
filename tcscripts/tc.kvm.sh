#!/bin/bash


echo_do()
{
	echo "$@"
	"$@"
}

#HOSTIP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | sed -e 's/addr://'`

#echo $HOSTIP

IFSPEED="21mbit"

VESPEED="256kbit"
VECEIL="20mbit"

LIMITSPEED="1mbit"
HALFLIMITSPEED="256kbit"

SHAPEIPS=`echo 208.64.38.105 208.64.38.112 208.64.38.118 208.64.38.122 208.64.38.123`
LIMITIPS="208.64.38.112"

LOWSPEED="128kbit"
LOWIPS="208.64.38.122"

addtc()
{
        echo_do tc qdisc del dev $DEV root

     	echo_do tc qdisc add dev $DEV root handle 1: htb r2q 16	
	sleep 1
	
      	echo_do tc class add dev $DEV parent 1: classid 1:1 htb rate "$IFSPEED" 
	
	CLASS="$FIRSTCLASS"	

	for IP in $SHAPEIPS
        do
		if `echo "$LIMITIPS" | grep "$IP" > /dev/null`
                then
			echo_do tc class add dev $DEV parent 1:1 classid 1:"$CLASS" htb rate "$LIMITSPEED"
			echo_do tc class add dev $DEV parent 1:"$CLASS" classid 1:$(($CLASS+1)) htb rate "$HALFLIMITSPEED" ceil "$LIMITSPEED" prio 0
			
                        echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 2222 0xffff flowid 1:$(($CLASS+1))
                        echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 2222 0xffff flowid 1:$(($CLASS+1))
			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 22 0xffff flowid 1:$(($CLASS+1))
                        echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 22 0xffff flowid 1:$(($CLASS+1))
			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip protocol 1 0xFF flowid 1:$(($CLASS+1))

			echo_do tc class add dev $DEV parent 1:"$CLASS" classid 1:$(($CLASS+2)) htb rate "$HALFLIMITSPEED" ceil "$LIMITSPEED" prio 1 

			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip dport 0x0 0xfc00 flowid 1:$(($CLASS+2))
                        echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" match ip sport 0x0 0xfc00 flowid 1:$(($CLASS+2))
				
			echo_do tc class add dev $DEV parent 1:"$CLASS" classid 1:$(($CLASS+3)) htb rate "$HALFLIMITSPEED" ceil "$LIMITSPEED" prio 2
			
			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:$(($CLASS+3))

			CLASS=$(($CLASS+4))

		elif `echo "$LOWIPS" | grep "$IP" > /dev/null`
		then	
			echo_do tc class add dev $DEV parent 1:1 classid 1:"$CLASS" htb rate "$LOWSPEED"
			echo_do tc qdisc add dev $DEV parent 1:"$CLASS" handle "$CLASS": sfq perturb 10

			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:"$CLASS"

			CLASS=$(($CLASS+1))
		else
			echo_do tc class add dev $DEV parent 1:1 classid 1:"$CLASS" htb rate "$VESPEED" ceil "$VECEIL" 
			echo_do tc qdisc add dev $DEV parent 1:"$CLASS" handle "$CLASS": sfq perturb 10
			
			echo_do tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip $1 "$IP" flowid 1:"$CLASS"

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
FIRSTCLASS="10"
addtc src


#DEV="venet0"
#FIRSTCLASS="10"
#addtc dst

DEV="kvm105"
FIRSTCLASS="10"
SHAPEIPS="208.64.38.105"
addtc dst

DEV="kvm112"
FIRSTCLASS="10"
SHAPEIPS="208.64.38.112"
addtc dst

#DEV="kvm118"
#FIRSTCLASS="10"
#SHAPEIPS="208.64.38.118"
#addtc dst

DEV="kvm122"
SHAPEIPS="208.64.38.122"
FIRSTCLASS="10"
addtc dst

DEV="kvm123"
SHAPEIPS="208.64.38.123"
FIRSTCLASS="10"
addtc dst
