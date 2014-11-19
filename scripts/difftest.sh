#!/bin/bash

NEWFILE="$1"
OLDFILE=$(echo $1 | sed -e 's/.rpmnew//')

diff $NEWFILE $OLDFILE
