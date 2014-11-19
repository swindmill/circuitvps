#!/bin/bash

ZIMBRACTL=/root/stuff/backup/scripts/zimbractl.sh
ZIMBRAHOST="mail.ampx.net"

HOSTNAME=`hostname -s`
VZLIST=/usr/sbin/vzlist
RSYNC="/usr/bin/rsync"
BACKUPVZ=""

export PYTHONPATH=/usr/local/rdiff-backup/lib64/python2.4/site-packages
RDIFF=/usr/local/rdiff-backup/bin/rdiff-backup

BASELOGDIR=/root/stuff/backup/logs

set_logdir()
{
        #LOGDATE=`date +%F.%H-%M-%S`
	LOGDATE="2009-03-02.23-56-52"
        LOGDIR="$BASELOGDIR/$HOSTNAME/$LOGDATE"

        if [ ! -d "$LOGDIR" ]
        then
                mkdir -p $LOGDIR
        fi

        MAINLOG="$LOGDIR/vzbackup.rdiff.log"
}

set_logdir

do_mail()
{

        OUTFILE="$LOGDIR".tar.bz2

        tar -C "$LOGDIR" -cf - . | bzip2 -9 > "$OUTFILE"

	mutt -s "$HOSTNAME backup report for $LOGDATE" -a "$OUTFILE" reports@circuitsupport.com < /dev/null

}

do_mail
