#!/bin/bash

if [ $# = 0 ]; then
	exit
fi

if [ $1 = "rsync" ]; then
	
	/sbin/lvcreate -L10G -s -nVZtemp /dev/VMs/OpenVZ

	/bin/mount -o ro /dev/VMs/VZtemp /vztemp

	dorsync () {

		if [ -e /vztemp/private/$1/.vpsbackupexclude ]; then

		nice -n15 ionice -c3 /usr/bin/rsync -avhH --stats --numeric-ids --delete --delete-excluded --exclude-from=/vztemp/private/$1/.vpsbackupexclude /vztemp/private/$1/ /esata/vzbackup/private/$1 &> /esata/vzbackup/$1.backup.log

		else


		nice -n 15 ionice -c3 /usr/bin/rsync -avhH --stats --numeric-ids --delete /vztemp/private/$1/ /esata/vzbackup/private/$1 &> /esata/vzbackup/$1.backup.log

		fi

	mail -s "VPS backup report for VEID $1" -a "From: reports@circuitsupport.com" reports@circuitsupport.com < /esata/vzbackup/$1.backup.log
	
	if [ $2 ];
	then
		mail -s "VPS backup report for 204.11.34.$1" -a "From: reports@circuitsupport.com" $2 < /esata/vzbackup/$1.backup.log
	fi
	
	}	

	dorsync 147
	dorsync 148 mooseboy@gmail.com
	dorsync 149 cvweiss@gmail.com 
	dorsync 150
	dorsync 151
	dorsync 152
	dorsync 153
	dorsync 154 mooseboy@gmail.com
        #dorsync 155
	dorsync 156 mystica@gmail.com
	dorsync 158 nirgle@gmail.com

	/bin/umount /vztemp

	/sbin/lvremove -f /dev/VMs/VZtemp

	if [ $# = 1 ]; then
	
		mail -s "VPS backup report" -a "From: reports@circuitsupport.com" reports@circuitsupport.com < /esata/vzbackup/vpsbackup.log

		exit
	fi

fi

if [ $2 = "gzip" ]; then

	dogzip () {

		#nice -n15 tar -cpf - --totals --numeric-owner -C /usbdrive/vzbackup/private/$1 . | nice -n15 gzip -c --rsyncable > /usbdrive/vzbackup/$1.tar.gz 
		#tar -cpf - --totals --numeric-owner -C /usbdrive/vzbackup/private/$1 . | gzip -c --rsyncable > /usbdrive/vzbackup/$1.tar.gz
		tar -cpf /usbdrive/vzbackup/$1.tar.gz --totals --numeric-owner -C /usbdrive/vzbackup/private/$1 .
	
	}	

	dogzip 147
	dogzip 148
	dogzip 149
	dogzip 150
	dogzip 151
	dogzip 152

fi

if [ $3 = "offsite" ]; then

	rsync -e 'ssh -c blowfish -ax' -vdW --delete --stats --rsync-path=~/bin/rsync /usbdrive/vzbackup/* windmills@milk.dreamhost.com:~/backups/vps/temp > /usbdrive/offsite.log 2>&1

fi


