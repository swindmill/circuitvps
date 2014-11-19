#/bin/bash

trafficlog=/root/vpsstats/traffic.log
switch=1

if [ -e "$trafficlog" ];
then
        rm $trafficlog
fi

for i in `cat /root/vpsstats/vpslist.txt` ;
do

   if [ "$switch" == "1" ] ;
   then
        echo -n `date "+%Y-%m-%d %H:%M:%S"` >> $trafficlog
        echo -n " $i " >> $trafficlog
   fi

   if [ "$switch" == "-1" ] ;
   then
        echo -n "$i " >> $trafficlog
        echo `/sbin/iptables -nvx -L | grep $i | grep 0.0.0.0 | tr -s [:blank:] | cut -d' ' -f3 | awk '{sum+=$1} END {print sum;}'` >> $trafficlog
   fi

   switch=$(($switch * -1))
done

if [ "$1" == "noscp" ] ;
then
        exit
fi

scp $trafficlog root@10.2.10.151:/var/www/vpsstats/traffic.log

wget -q http://10.2.10.151/vpsstats/traffic-read.php -O /dev/null

/sbin/iptables -Z
