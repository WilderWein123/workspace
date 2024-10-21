#!/bin/bash
cd /scripts
echo $(date)>>/var/log/backups/current.log
echo "FULL COPY STARTED!">>/var/log/backups/current.log
NUMBER=$(wc list2 | awk '{print $1}')
NUMBER=$[NUMBER+1]
for ((i=1; i < $NUMBER; i++))do
        cd /scripts
        TEMP1=`cat list2 | head -n${i} | tail -n1`
        cd /volume1/bkp-sql/obs/${TEMP1}/Week/Full
        TEMP2=$(find . -mtime -7 -type f)
                echo $(date)>>/var/log/backups/current.log
                echo "COPY STARTED FOR $TEMP1">>/var/log/backups/current.log
                find . -mtime -7 -type f -exec cp -n -p {} /volume1/bkp-sql/received/Full/${TEMP1} \;
                RESULT=$(echo $?)
#if cp errorcode is 1 - shit happends. Interrupting scripts.
                if [ $RESULT = 1 ];then
                        echo "COPY INTERRUPTED!">>/var/log/backups/current.log
                        echo "COPY INTTERUPTED!">/volume2/logs/log
                        rm /volume2/logs/log4
                        exit
#else writing zabbix log and goto next
                        else echo $(date)" FULL COPY COMPLETED for "$TEMP1>>/volume2/logs/log
        fi
done
chmod 777 /volume2/logs/*
cd /scripts
./03-postcopy.sh
