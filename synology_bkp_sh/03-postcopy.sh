#!/bin/bash
cd /scripts
NUMBER=$(wc list2 | awk '{print $1}')
NUMBER=$[NUMBER+1]
RESULT1=0
RESULT2=0
>/var/log/backups/compare.log
echo $(date)>>/var/log/backups/current.log
echo "POSTCOPY STARTED">>/var/log/backups/current.log
date1=$(date +%Y"-"%m"-"%d -d "-7 day")
log=$(cat /volume2/logs/log | wc -l )
if [[ $log != 4 ]];then exit
fi
for ((i=1; i < $NUMBER; i++))do
        cd /scripts
        temp1=`cat list2 | head -n${i} | tail -n1`
        cd /volume1/bkp-sql/obs/${temp1}/Week/Full
        RESULT1=$(find . -type f -mtime -7 -exec basename {} \; | sort )
        cd /volume1/bkp-sql/received/Full
        find . -type f -newermt 2010-01-01 ! -newermt $date1 -exec rm {} \;
        cd /volume1/bkp-sql/received/Full/${temp1}/
        RESULT2=$(find . -type f -exec basename {} \; | sort )
        DIFF=$(diff <(echo "$RESULT1") <(echo "$RESULT2"))
        if [[ $DIFF = "" ]];then
                echo "POSTCOPY COMPARE OK for $temp1">>/var/log/backups/current.log
                echo $(date)" "$temp1>>/var/log/backups/current.log
                else
                echo $(date)" "$temp1>>/var/log/backups/current.log
                echo "POSTCOPY COMPARE FAILED for $temp1!!!">>/var/log/backups/current.log
        fi
        echo "COMPARE REPORT FOR $temp1">>/var/log/backups/compare.log
        echo $DIFF>>/var/log/backups/compare.log
done
cp /var/log/backups/current.log /var/log/backups/$(date +%y%m%d)-log
cp /var/log/backups/compare.log /var/log/backups/$(date +%y%m%d)-comparelog
cp /var/log/backups/diff.log /var/log/backups/$(date +%y%m%d)-difflog
>/var/log/backups/diff.log
chmod 777 /volume2/logs/*
rm /volume2/logs/log4
