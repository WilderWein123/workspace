#!/bin/bash
#generating cluster list
/opt/1cv8/x86_64/8.3.19.1467/rac cluster list | grep "cluster                       :" | awk '{print $3}' > /scripts/data/clusters
#generating session list
allow=50
counter=$(cat /scripts/data/clusters | wc -l)
license="8100455676"
echo $(date '+%Y-%m-%d %H:%M:%S')" 1c license checker started!"
mkdir /scripts/data > /dev/null
for ((a=1;a < $counter+1; a++)) do
        clustername=$(cat /scripts/data/clusters | head -n $a)
        echo $(date '+%Y-%m-%d %H:%M:%S')" processing cluster "$clustername
                used=$(/opt/1cv8/x86_64/8.3.19.1467/rac session list --licenses --cluster=$clustername | grep full-presentation | grep $license | wc -l)
                echo $(date '+%Y-%m-%d %H:%M:%S')" Used "$used" licenses from "$license
        if [[ $used -gt $allow ]]; then
                /opt/1cv8/x86_64/8.3.19.1467/rac session list --licenses --cluster=$clustername | grep -e $license -e 'session' | grep 'session' | awk '{print $3}' > /scripts/data/$license
                while [[ $used -gt $allow ]]
                do
                        for ((b=1;b < (used-allow+1); b++)) do
#                       lastsession=$(/opt/1cv8/x86_64/8.3.19.1467/rac session list --cluster=$clustername | grep -e 'duration-all                     :' -e 'session                          :' | sed -n ${b}p | awk '{print $3}')
                        lastsession=$(cat /scripts/data/${license} | sed -n ${b}p)
                        ((used=used - 1))
                        #/opt/1cv8/x86_64/8.3.19.1467/rac session cluster=$clustername terminate --session=$lastsession
                        echo $(date '+%Y-%m-%d %H:%M:%S')" Session "$lastsession" stopped. "$used" liceses used now"
                        done
                done
        else
                echo $(date '+%Y-%m-%d %H:%M:%S')" Nothing to do"
        fi
done
