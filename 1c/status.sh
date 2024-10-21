#!/bin/bash
#zabbix userparatmeres
#UserParameter=server.discovery,/scripts-oit/status.sh server.discovery
#UserParameter=license.discovery,/scripts-oit/status.sh license.discovery
#UserParameter=licenses.total.number[*],/scripts-oit/status.sh licenses.total.number $1
#UserParameter=licenses.used.byserver[*],/scripts-oit/status.sh licenses.used.byserver $1
#UserParameter=licenses.total.used[*],/scripts-oit/status.sh licenses.total.used $1
#UserParameter=sessions.total[*],/scripts-oit/status.sh sessions.total $
if ! [[ $1 ]]; then exit 0; fi
configpath="/scripts-oit/conf.d"
racpath="/opt/1cv8/x86_64/8.3.22.1750"
servers=$(cat $configpath/appservers.conf  | grep appserver | awk -F '==' {'print $NF'})
if [[ $1 = 'server.discovery' ]]; then
        lastsrv=$(echo $servers | awk '{print $NF}')
	echo '{'
        echo ' "data":['
        for i in ${servers[@]}; do
		echo '  {'
		printf '   "{#APPSRVR}": "'
		printf $i'"\n'
		if [[ $i = $lastsrv ]]; then
			echo ' }'
			else
			echo ' },'
		fi
	done
echo ' ]'
echo '}'
fi
if [[ $1 = 'license.discovery' ]]; then
	licenses=$(cat $configpath/licservers.conf | grep licserver | awk -F '==' {'print $NF'} | sort | uniq)
        echo '{'
        echo ' "data":['
	lastlic=$(echo $licenses | awk '{print $NF}')
	for i in ${licenses[@]}; do
                echo '  {'
                printf '   "{#LICSRVR}": "'
                printf $i'"\n'
                if [[ $i = $lastlic ]]; then
                        echo ' }'
                        else
                        echo ' },'
                fi
	done
echo ' ]'
echo '}'
fi
if [[ $1 = 'licenses.total.number' ]]; then
	cat $configpath/licservers.conf | grep -A1 $2 | grep licnumber | head -n 1 | awk -F '==' {'print $NF'}
fi
if [[ $1 = 'licenses.used.byserver' ]];then
	cluster=$($racpath/rac cluster list $2:1545 | head -n 1 | awk {'print $NF'})
		if [[ $(cat $configpath/appservers.conf | grep -A2 $2 | grep 'admin') ]]; then
			admin=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'admin' | awk -F '==' {'print $2'} | head -n 1)
			password=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'password' | awk -F '==' {'print $2'} | tail -n 1)
			licnum=$($racpath/rac session list --cluster-user=$admin --cluster-pwd=$password --licenses --cluster=$cluster $2:1545 | grep soft | wc -l)
			echo $licnum
		else
			licnum=$($racpath/rac session list --licenses --cluster=$cluster $2:1545 | grep soft | wc -l)
			echo $licnum
		fi
fi
if [[ $1 = 'licenses.total.used' ]]; then
	servers=$(cat $configpath/appservers.conf  | grep -B1 $2 | grep appserver | awk -F '==' {'print $2'})
	licnum=0
	for i in ${servers[@]}; do
	cluster=$($racpath/rac cluster list $i:1545 | head -n 1 | awk {'print $NF'})
                if [[ $(cat $configpath/appservers.conf | grep -A2 $2 | grep 'admin') ]]; then
                        admin=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'admin' | awk -F '==' {'print $2'} | head -n 1)
                        password=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'password' | awk -F '==' {'print $2'} | tail -n 1)
                        licnum=$(($licnum+$($racpath/rac session list --cluster-user=$admin --cluster-pwd=$password --licenses --cluster=$cluster $i:1545 | grep soft | wc -l)))
                else
                        licnum=$(($licnum+$($racpath/rac session list --licenses --cluster=$cluster $i:1545 | grep soft | wc -l)))
                fi
	done
echo $licnum
fi
if [[ $1 = 'sessions.total' ]];then
        cluster=$($racpath/rac cluster list $2:1545 | head -n 1 | awk {'print $NF'})
                if [[ $(cat $configpath/appservers.conf | grep -A2 $2 | grep 'admin') ]]; then
                        admin=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'admin' | awk -F '==' {'print $2'} | head -n 1)
                        password=$(cat $configpath/appservers.conf | grep -A3 $2 | grep 'password' | awk -F '==' {'print $2'} | tail -n 1)
                        sessnum=$($racpath/rac session list --cluster-user=$admin --cluster-pwd=$password --cluster=$cluster $2:1545 | grep 'app-id' | grep -v 'BackgroundJob' | grep -v 'Designer' | grep -v 'WSConnection' | wc -l)
                        echo $sessnum
                else
			sessnum=$($racpath/rac session list --cluster=$cluster $2:1545 | grep 'app-id' | grep -v 'BackgroundJob' | grep -v 'Designer' | grep -v 'WSConnection' | wc -l)
                        echo $sessnum
                fi
fi
