#!/bin/bash

HOME="/home/kvm"
ISO="$HOME/iso"
BIN="$HOME/bin"
MON="$HOME/mon"
CONF="$HOME/conf"

BONDIP=`ifconfig bond0 | grep "inet addr" | awk '{print $2}' | sed -e 's/addr://g'`

if [ $# = 1 ]
then
        if $BIN/running.sh $1
        then
                . $CONF/$1.conf
                echo will migrate $1
                sudo /sbin/ip route del $IP

                if [ $BONDIP = "192.168.1.1" ]
                then
                        MIGTOIP="192.168.1.2"
                elif [ $BONDIP = "192.168.1.2" ]
                then
                        MIGTOIP="192.168.1.1"
                fi

                #echo "migrate tcp:$MIGTOIP:$MIGPORT" | socat - UNIX-CONNECT:$MONITOR
                ssh $MIGTOIP sudo /sbin/ip route add $IP dev $IFNAME
        	ssh $MIGTOIP sudo /usr/local/sbin/arpsend -U -i $IP -c 10 eth0
	else
                echo instance is not running
        fi
else
        echo must specify an instance number
fi
