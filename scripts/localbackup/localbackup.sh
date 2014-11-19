#!/bin/bash

nice -n15 ionice -c3 /usr/bin/rsync -avrhH --stats --whole-file --numeric-ids --delete --delete-excluded --files-from=/root/localbackup/backuplist.dat --exclude-from=/root/localbackup/excludelist.dat / /esata/localbackup 
# &> /usbdrive/local.backup.log

#mail -s "pandora backup report" -a "From: reports@circuitsupport.com" reports@circuitsupport.com < /usbdrive/local.backup.log
