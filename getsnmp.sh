#!/bin/bash
set -e
	
date=`date +"%y-%m-%d-%H"`

sysname=`snmpbulkwalk -Obn -v2c -c mupp3t $1 sysName`

if [[ $sysname == *Timeout* ]]
then
	echo $1 >> error.log
	echo "borked"
fi

mkdir -p data/$1/$date
echo -n "Getting ARP Table for $1 ...."
snmpbulkwalk -Obn -v2c -c mupp3t $1 .1.3.6.1.2.1.3.1.1.2 > data/$1/$date/arptable
echo "done"
echo -n "Getting Vlan Names for $1 ...."
snmpbulkwalk -Obn -v2c -c mupp3t $1 .1.3.6.1.4.1.9.9.46.1.3.1.1.4.1 > data/$1/$date/vlannames
echo "done"
echo -n "Getting Interface descriptions for $1 ...."
snmpbulkwalk -Obn -v2c -c mupp3t $1 ifdescr > data/$1/$date/ifdescr
echo "done"
echo -n "Getting Interface Aliases for $1 ...."
snmpbulkwalk -Obn -v2c -c mupp3t $1 ifname > data/$1/$date/ifalias
echo "done"
echo -n "Getting MAC Addresses for $1 vlan "
for i in $(cat data/$1/$date/vlannames  | cut -d "=" -f1 | tr -sd " " "" | cut -d "." -f 17)
 do
   echo -n "$i "
   snmpbulkwalk -Obn -v2c -c mupp3t@$i  $1 .1.3.6.1.2.1.17.4.3.1.1 | tr " " ":" | awk -F: '{printf("%02s:%02s:%02s:%02s:%02s:%02s\n",$5,$6,$7,$8,$9,$10)}' >  data/$1/$date/macaddrs.vlan$i
 done
echo "...done"

echo -n "Getting Port to MAC info for $1 vlan "
for i in $(cat data/$1/$date/vlannames  | cut -d "=" -f1 | tr -sd " " "" | cut -d "." -f 17)
 do
   echo -n "$i "
   snmpbulkwalk -Obn -v2c -c mupp3t@$i  $1 .1.3.6.1.2.1.17.4.3.1.2 >  data/$1/$date/dbport.vlan$i
 done
echo "...done"

echo -n "Getting Port to Interface info for $1 vlan "
for i in $(cat data/$1/$date/vlannames  | cut -d "=" -f1 | tr -sd " " "" | cut -d "." -f 17)
 do
   echo -n "$i "
   snmpbulkwalk -Obn -v2c -c mupp3t@$i  $1 .1.3.6.1.2.1.17.1.4.1.2 >  data/$1/$date/dbporttoifindex.vlan$i
 done
echo "...done"

