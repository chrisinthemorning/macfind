#!/bin/bash
# run this command like this
# cat ip | xargs -P 4 -I zz ./getsnmp.sh zz community

date=`date +"%y-%m-%d-%H"`

sysname=`snmpbulkwalk -Obn -v2c -c $2 $1 sysName`

if [[ $sysname == *Timeout* ]]
then
        echo $1 >> error.log
        exit
fi

mkdir -p data/$1/$date

echo $sysname > data/$1/$date/sysname

echo -n "Getting ipAddrTable for $1 ...."
        snmpbulkwalk  -Obn -v2c -c $2 $1  .1.3.6.1.2.1.4.20.1 > data/$1/$date/ipaddrtable
echo "done"

echo -n "Sending Ping to "
	for i in $(grep ".1.3.6.1.2.1.4.20.1.1\."  data/$1/$date/ipaddrtable  |  cut -d "=" -f2 | tr -sd " " "" | cut -d ":" -f2)
	do
		smask=`grep ".1.3.6.1.2.1.4.20.1.3.$i "  data/$1/$date/ipaddrtable  |  cut -d "=" -f2 | tr -sd " " "" | cut -d ":" -f2`
		netid=`ipcalc -nbc  $i $smask  | grep Network | cut -d":" -f2 | tr -sd " " ""`
		echo -n "$netid "
	 	fping -t1 -i1 -c1 -r1  -qg $netid  >/dev/null 2>&1
	done
echo "...done"

echo -n "Getting ARP Table for $1 ...."
snmpbulkwalk -Obn -v2c -c $2 $1 .1.3.6.1.2.1.3.1.1.2 > data/$1/$date/arptable
echo "done"

echo -n "Getting Vlan Names for $1 ...."
snmpbulkwalk -Obn -v2c -c $2 $1 .1.3.6.1.4.1.9.9.46.1.3.1.1.4.1 > data/$1/$date/vlannames
echo "done"

echo -n "Getting Interface names and aliases for $1 ...."
snmpbulkwalk -Obn -v2c -c $2 $1 .1.3.6.1.2.1.31.1.1.1 > data/$1/$date/iftable
	grep ".1.3.6.1.2.1.31.1.1.1.18\." data/$1/$date/iftable > data/$1/$date/ifalias
	grep ".1.3.6.1.2.1.31.1.1.1.1\." data/$1/$date/iftable > data/$1/$date/ifname
echo "done"

sleep 5

echo -n "Getting forwarding table for $1 vlan "
for i in $(cat data/$1/$date/vlannames  | cut -d "=" -f1 | tr -sd " " "" | cut -d "." -f 17)
	do
		echo -n "$i "
		snmpbulkwalk -Obn -v2c -c $2@$i  $1 .1.3.6.1.2.1.17 >  data/$1/$date/fwdtable.vlan$i
		grep ".1.3.6.1.2.1.17.4.3.1.1\." data/$1/$date/fwdtable.vlan$i | tr " " ":" | awk -F: '{printf("%s:%02s:%02s:%02s:%02s:%02s:%02s\n",$1,$5,$6,$7,$8,$9,$10)}' >  data/$1/$date/macaddrs.vlan$i
		grep ".1.3.6.1.2.1.17.4.3.1.2\." data/$1/$date/fwdtable.vlan$i >  data/$1/$date/dbport.vlan$i
		grep ".1.3.6.1.2.1.17.1.4.1.2\." data/$1/$date/fwdtable.vlan$i >  data/$1/$date/dbporttoifindex.vlan$i
	done
echo "...done"
