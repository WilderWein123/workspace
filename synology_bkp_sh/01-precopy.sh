#!/bin/bash
cd /scripts
NUMBER=$(wc list | awk '{print $1}')
NUMBER=$[NUMBER+1]
RESULT1=0
RESULT2=0
touch /volume2/logs/log4
>/scripts/list2
>/volume2/logs/log
echo $(date)>/var/log/backups/current.log
echo "PRECOPY STARTED!">>/var/log/backups/current.log
cd /volume1/bkp-sql/obs/
rm /volume2/logs/log
A=$(find -maxdepth 1)
#checking source files. If no files detected callin script interrupt.
if [[ $A = "" ]];then
        echo "NOTHING TO BACKUP. CKECK SOURCE.">/volume2/logs/log
        echo "NOTHING TO BACKUP. CHECK SOURCE.">>/var/log/backups/current.log
        rm /volume2/logs/log4
        exit
fi
for ((i=1; i < $NUMBER; i++))do
        DIFF=0
        RESULT1=0
        RESULT2=0
        cd /scripts
        temp1=`cat list | head -n${i} | tail -n1`
        cd /volume1/bkp-sql/obs/${temp1}/Week/Full
        RESULT1=$(find . -mtime -7 -type f -exec basename {} \; | sort)
        cd /volume1/bkp-sql/received/Full/${temp1}
        RESULT2=$(find . -mtime -7 -type f -exec basename {} \; | sort)
#Checking source and target files
        DIFF=$(diff <(echo "$RESULT1") <(echo "$RESULT2"))
        if [[ $DIFF = "" ]];then
#DIFF is zero, then goto next
                        echo "PRECOPY - NO FULL BACKUPS for $temp1">>/var/log/backups/current.log
                        echo $(date)" NO BACKUPS for  "$temp1>>/volume2/logs/log
                else
#DIFF is not zero, include this folder to copy list
                        echo "PRECOPY FULL BACKUPS FOUND for $temp1">>/var/log/backups/current.log
                        echo $temp1>>/scripts/list2
        fi
done
chmod 777 /volume2/logs/*
cd /scripts
./02-copy.sh
