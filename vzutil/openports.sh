#!/bin/bash

OLDIFS="$IFS"
IFS=";"

PORTSFILE="/root/stuff/vzutil/ports"

while read LINE
do 
	read -a ARRAY <<< "$LINE"

	IP="${ARRAY[0]}"
	unset ARRAY[0]
	
	for RULE in "${ARRAY[@]}"
	do	
		RULE1=`echo "$RULE" | awk '{ print $1 }'`
		RULE2=`echo "$RULE" | awk '{ print $2 }'`
		RULE3=`echo "$RULE" | awk '{ print $3 }'`	
		if [ "$RULE1" == "*" ]
		then
			COMMAND="-A FORWARD -d "$IP" -p "$RULE2" --dport "$RULE3" -j ACCEPT"
		else
			COMMAND="-A FORWARD -s "$RULE1" -d "$IP" -p "$RULE2" --dport "$RULE3" -j ACCEPT"
		fi
		echo "$COMMAND"
	done	

	echo "-A FORWARD -d "$IP" -m state --state ESTABLISHED,RELATED -j ACCEPT"
        echo "-A FORWARD -d "$IP" -j DROP"
        echo

done < <(cat "$PORTSFILE")
