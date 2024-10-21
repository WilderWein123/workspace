#!/bin/bash
dow=$(date +%u)
if [[ $dow = 1 ]];then
        date1=$(date +%Y"-"%m"-"%d -d "-4 day")
        else
        date1=$(date +%Y"-"%m"-"%d -d "-2 day")
fi
cd /volume1/bkp-sql/received/Diff
find . -type f -newermt 2010-01-01 ! -newermt $date1 -exec rm {} \;
chmod 777 /volume2/logs/*
rm /volume2/logs/log4

