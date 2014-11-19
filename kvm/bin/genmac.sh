#!/bin/sh
# generate a random mac address for the qemu nic
# shell script borrowed from user pheldens @ qemu forum

echo $(echo -n KVMMAC=\"DE:AD:BE:EF ; for i in `seq 1 2` ;
do echo -n `echo ":$RANDOM$RANDOM" | cut -n -c -3` ;done)\"

echo $(echo -n  TAPMAC=\"DE:AD:BE:EF ; for i in `seq 1 2` ;
do echo -n `echo ":$RANDOM$RANDOM" | cut -n -c -3` ;done)\"
