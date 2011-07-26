#!/bin/bash

if test -z "$2"
then
	searchregex="*"
else
	searchregex=$2
fi
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
IFS=$(echo -en "\n\b")
#echo "Search for IP $1 ...."

	for i in $(grep -i $1 data/*/$searchregex/arptable  | sort -k6 | uniq -f3)
	 do
	  macaddr=`echo $i | cut -f3 -d ":" | tr " " ":" | cut -b 2-18`
	  echo "IP $1 has MAC $macaddr "
	  ./find.sh $macaddr
	 done
#	echo "Finished IP Search"

else
#	echo -n "Search for MAC $1 ...."

	for i in "$(grep -i $1  data/*/$searchregex/macaddrs.*)"
	 do
#	  echo "found"
	  echo "$i"
	 done
#	echo "Finished MAC Search"
fi


