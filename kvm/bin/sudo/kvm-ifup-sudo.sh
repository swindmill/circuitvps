#!/bin/sh
set -x

BIN=/home/kvm/bin

if [ $# = 3 ];then
        if ! $BIN/ip link show $1 &> /dev/null
	then
		$BIN/tunctl -u kvm -t $1
		sleep 0.5s
        	$BIN/ifconfig $1 hw ether $2
	fi
       	$BIN/ifconfig $1 0
       	sleep 0.5s
       	if [ $3 != "noip" ]
	then
		ROUTE=`$BIN/ip route show $3`
		if [ ! -n "$ROUTE" ] 
		then
			$BIN/ip route add $3 dev $1
		fi
	fi
	echo 1 > /proc/sys/net/ipv4/conf/$1/proxy_arp
       	echo 1 > /proc/sys/net/ipv4/conf/eth0/proxy_arp
	exit 0
else
        echo "Error: wrong number of arguments passed"
        exit 1
fi
