#!/bin/bash

if ! dpkg-query -W -f'${Status}' "ipcalc" 2>/dev/null | grep -q "ok installed"; then
	echo "ipcalc package not found"
	exit
fi

if [ $# -eq 0 ]; then
	echo "usage: ./jajookup.sh 0.0.0.0/0"
	exit
fi

cidr=$1

ipstart=$(ipcalc -b $cidr | grep "HostMin" | cut -d ':' -f 2)
ipend=$(ipcalc -b $cidr | grep "HostMax" | cut -d ':' -f 2)

read g o a t <<< $(echo $ipstart | tr . ' ')
read e l f i <<< $(echo $ipend | tr . ' ')

allip="$(eval "echo {$g..$e}.{$o..$l}.{$a..$f}.{$t..$i}")"

for currentip in $allip; do
	lookupresult=`nslookup $currentip`
	if [[ ${lookupresult} != *"server can't find"* ]];then
		echo $currentip" ======> "${lookupresult##*= }
		echo $currentip" ======> "${lookupresult##*= } >> result.txt
	fi
done

echo "Result in result.txt"