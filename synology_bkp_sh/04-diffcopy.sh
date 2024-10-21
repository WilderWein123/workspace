#!/bin/bash
cd /scripts
if [ -f "/volume2/logs/log4" ];then
        echo "SECOND LAUNCH ABORTED!">>/var/log/backups/diff.log
        exit
fi
touch /volume2/logs/log4
echo $(date)>>/var/log/backups/diff.log
echo "DIFF COPY STARTED!">>/var/log/backups/diff.log
NUMBER=$(wc list | awk '{print $1}')
NUMBER=$[NUMBER+1]
cd /volume1/bkp-sql/obs
A=$(find -maxdepth 1)
if [[ $A = "" ]];then
        echo CHECK SOURCE>>/var/log/backups/diff.log
        echo CHECK SOURCE>> /volume2/logs/log3
        rm /volume2/logs/log4
        exit
fi
for ((i=1; i < $NUMBER; i++))do
        cd /scripts
        TEMP1=`cat list | head -n${i} | tail -n1`
        cd /volume1/bkp-sql/obs/${TEMP1}/Week/DiffDay
        echo $(date)>>/var/log/backups/diff.log
        echo "COPY STARTED FOR $TEMP1">>/var/log/backups/diff.log
        find . -mtime -3 -type f -exec cp -n -p {} /volume1/bkp-sql/received/Diff/${TEMP1} \;
        RESULT=$(echo $?)
#if cp errorcode is 1 - shit happends. Interrupting scripts.
        if [ $RESULT = 1 ];then
            echo "COPY INTERRUPTED!">>/var/log/backuips/current.log
            echo "COPY INTERRUPTED!">/volume2/logs/log
            rm /volume2/logs/log4
            exit
            else echo $(date)" DIFF COPY COMPLETED for "$TEMP1>>/volume2/logs/log2
        fi
done
chmod 777 /volume2/logs/*
cd /scripts
./05-diffclear.sh
