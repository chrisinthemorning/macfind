#!/bin/bash
# run command like this
#  ./changevlan.sh 10.60.47.199 community 22 1234 5678
# where 2nd arg is the community, 3rd arg is the ifindex, 
# 4th arg is the current vlan on that port (sanity check), 5th arg is the new vlan


currentvlan=`snmpget -Obn -v2c -c $2 $1 1.3.6.1.4.1.9.9.68.1.2.2.1.2.$3 | cut -d ":" -f2 | tr -ds " " ""`

if [ $4 == $currentvlan ]
	then
		outputcode=`snmpset -Obn  -v1 -c $2 10.60.48.9 1.3.6.1.4.1.9.9.68.1.2.2.1.2.$3 integer $5  | cut -d ":" -f2 | tr -ds " " ""`
		if [ $outputcode == $5 ]
			then
				echo "Success"
			else
				echo "Fail"
		fi
else
	echo "Current vlan doesn't match"
fi

