#!/bin/bash
# run command like this
#  ./find.sh 10.60.47.199 11-07-26-10
# where seconf arg is date format, if not specified will default to searching current hour of data
# you can use ip or mac for arg 1

if test -z "$2"
then
	searchregex=`date +"%y-%m-%d-%H"`
else
	searchregex=$2
fi
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
IFS=$(echo -en "\n\b")
	for i in $(grep -i $1 data/*/$searchregex/arptable  | sort -r -k6 | uniq -f3 )
	 do
	  macaddr=`echo $i | cut -f3 -d ":" | tr " " ":" | cut -b 2-18`
	  echo "IP $1 has MAC $macaddr "
	 done
else
	echo -e "vlan,ifDescr,ifAlias,sysname,path"
	for i in $(grep -i $1  data/*/$searchregex/macaddrs.*)
	do
	vlan=`echo $i | cut -d "." -f 5 | cut -d ":" -f 1`
	dbport=`echo $i | cut -d "." -f 17-100 | cut -d ":" -f 1`
	nodepath=`echo $i | cut -d "/" -f 1-3`
	dbportnum=`grep ".1.3.6.1.2.1.17.4.3.1.2.$dbport " $nodepath/dbport.$vlan | cut -d":" -f2 | tr -ds " " ""`
	ifindex=`grep ".1.3.6.1.2.1.17.1.4.1.2.$dbportnum " $nodepath/dbporttoifindex.$vlan| cut -d ":" -f2 | tr -ds " " ""`
	ifalias=`grep .1.3.6.1.2.1.31.1.1.1.1.$ifindex $nodepath/ifalias | cut -d ":" -f2 | tr -ds " " ""`
	ifdescr=`grep .1.3.6.1.2.1.2.2.1.2.$ifindex $nodepath/ifdescr | cut -d ":" -f2 | tr -ds " " ""`
	sysname=`cat $nodepath/sysname | cut -d ":" -f2 | tr -ds " " ""`
	echo $vlan,$ifdescr,$ifalias,$sysname,$nodepath
	done
fi


