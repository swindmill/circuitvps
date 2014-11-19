#!/bin/bash

HOSTNAME=`hostname -s`

OPENPORTS="/root/stuff/vzutil/openports.sh"

HOSTIP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | sed -e 's/addr://'`

HOSTSSHPORT="2292"

HOSTIPS="208.64.38.98 208.64.38.99"

HOSTIPS="${HOSTIPS/$HOSTIP/}"

VZIPS=`echo 208.64.38.{101..127}`

VZNET="208.64.38.96/27"

INTNET="192.168.1.0/24"

MAILSERVER="208.64.38.105"

BLOCKEDOUT=""

PANEL="208.64.38.106"

echo *filter

echo -N ACCOUNT

echo "#HOST IP TRAFFIC ACCOUNTING"
echo
echo -A INPUT -d $HOSTIP -j ACCOUNT
echo -A OUTPUT -s $HOSTIP -j ACCOUNT
echo

echo "#DENY ACCESS TO OTHER NOST NODE(S)"
echo
for HNIP in "$HOSTIPS"
do
	#echo -A FORWARD -s $PANEL -d $HNIP -p tcp --dport 2292 -j ACCEPT
	#echo -A FORWARD -s $MAILSERVER -d $HNIP -p tcp --sport 25 -j ACCEPT
	echo -A FORWARD -d $HNIP -j DROP
done
echo

echo "#DENY ACCESS TO INTERNAL NETWORK"
echo

echo -A INPUT -s "$VZNET" -d "$INTNET" -j DROP 
echo -A FORWARD -d "$INTNET" -j DROP 
echo

echo "#VZ IP TRAFFIC ACCOUNTING"
echo
for IP in $VZIPS
do
        echo -A FORWARD -s $IP -j ACCOUNT
        echo -A FORWARD -d $IP -j ACCOUNT
        echo
done


echo "#ALLOW ACCESS TO HOST NODE"
echo

#echo -A INPUT -s $PANEL -d $HOSTIP -p tcp --dport "$HOSTSSHPORT" -j ACCEPT
#echo -A INPUT -s 99.235.243.10 -d $HOSTIP -p tcp --dport 5903 -j ACCEPT
echo -A INPUT -s ! "$VZNET" -d $HOSTIP -p tcp --dport "$HOSTSSHPORT" -j ACCEPT
echo -A INPUT -d $HOSTIP -m state --state ESTABLISHED,RELATED -j ACCEPT
echo -A INPUT -d $HOSTIP -j DROP
echo


if [ -n "$BLOCKEDOUT" ]
then
	echo "#BLOCKED IPs = "$BLOCKEDOUT""
	echo
	for BLOCKEDIP in $BLOCKEDOUT
	do
		echo -A FORWARD -s $BLOCKEDIP -j DROP
		echo -A FORWARD -d $BLOCKEDIP -j DROP
		VZIPS="${VZIPS/$BLOCKEDIP/}"
	done
	echo
fi

echo
echo "#OPENING SPECIFIC PORTS"
echo
$OPENPORTS
echo

echo COMMIT
