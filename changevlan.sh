#!/bin/bash
# run command like this
#  ./changevlan.sh 10.60.47.199 community 22 1234 5678
# where 2nd arg is the community, 3rd arg is the ifindex, 
# 4th arg is the current vlan on that port (sanity check), 5th arg is the new vlan


currentvlan=`snmpget -Obn -v2c -c $2 $1 1.3.6.1.4.1.9.9.68.1.2.2.1.2.$3 | cut -d ":" -f2 | tr -ds " " ""`

if [ $4 == $currentvlan ]
	then
	trunkmode=`snmpget -Obn -v2c -c $2 $1 1.3.6.1.4.1.9.9.46.1.6.1.1.16.$3 | cut -d ":" -f2 | tr -ds " " ""`
	if [ $trunkmode == "notApplicable(6)" ]
		then
			outputcode=`snmpset -Obn  -v1 -c $2 $1 1.3.6.1.4.1.9.9.68.1.2.2.1.2.$3 integer $5  | cut -d ":" -f2 | tr -ds " " ""`
			if [ $outputcode == $5 ]
				then
					echo "Success"
					transaction=$RANDOM
                                        snmpset -Obn  -v1 -c $2 $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.3.$transaction integer 4  >/dev/null 2>&1
                                        snmpset -Obn  -v1 -c $2 $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.4.$transaction integer 3  >/dev/null 2>&1
                                        snmpset -Obn  -v1 -c $2 $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.14.$transaction integer 1  >/dev/null 2>&1
					echo "Writing from Memory to Startup config in switch $1"
					sleep 3
                                        writesuccess=`snmpget -Obn -v2c -c $2 $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.10.$transaction  | cut -d ":" -f2 | tr -ds " " ""`
					if [ $writesuccess == "3" ]
						then
						echo "Write Success"
						else
						echo "Write Failed code=$writesuccess Transacation=$transaction"
					fi

				else
					echo "Failed setting new vlan $outputcode"
			fi
		else 
			echo "Fail - Trunked port"
		fi
else
	echo "Current vlan doesn't match sanity check"
fi

