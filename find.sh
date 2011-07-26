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
	for i in $(grep -i $1 data/*/$searchregex/arptable  | sort -r -k6 | uniq -f3)
	 do
	  macaddr=`echo $i | cut -f3 -d ":" | tr " " ":" | cut -b 2-18`
	  echo "IP $1 has MAC $macaddr "
	  ./find.sh $macaddr $searchregex 
	 done
else
	for i in "$(grep -i $1  data/*/$searchregex/macaddrs.*)"
	 do
	  echo "$i"
	 done
fi


