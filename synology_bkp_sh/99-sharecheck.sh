#!/bin/bash
>/volume2/logs/log3
A=$(find -maxdepth 1)
#checking source files. If no files detected callin script interrupt.
if [[ $A = "" ]];then
        echo "NOTHING TO BACKUP. CKECK SOURCE.">/volume2/logs/log
        echo "NOTHING TO BACKUP. CHECK SOURCE.">>/var/log/backups/current.log
        echo "SHARE FAULT!">/volume2/logs/log3
        exit
fi

