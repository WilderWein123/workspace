#!/bin/bash
if [ -z $2 ]; then
	echo 'missing parameter'
	echo 'usage scripts.sh <yandex_token> <path to script>'
	exit 1
fi
apt install idn -y > /dev/null 2>/dev/null
TOKEN=$1
NAME=$(date +%Y%m%d)
cd $2
rm -rf $NAME
mkdir -p $NAME/JSON
PAGETOKEN=1
FILE=$NAME/orglist
echo $(date)'-------processing organizations-------'
DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org?pageToken=$PAGETOKEN | jq)
echo '   REQUEST curl -s --header "Authorization: OAuth '$TOKEN'" https://api360.yandex.net/directory/v1/org?pageToken='$PAGETOKEN' | jq'
while [ -n "$(echo $DATA | grep organizations)" ]; do
        echo $DATA | jq >> $NAME/JSON/orglist.json
        echo $DATA | jq | grep -e name -e id | awk '{print $NF}' | awk -F ',' {'print $1'} | tr -d '"' >> $FILE.txt
        PAGETOKEN=$(($PAGETOKEN+1))
        DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org?pageToken=$PAGETOKEN | jq)
done
LIST=$(cat $NAME/orglist.txt | sed -n '0~2!p')
echo $(date)'-------processing domains-------'
for i in $LIST; do
FILE=$NAME/domains
PAGETOKEN=1
        DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org/$i/domains?page=$PAGETOKEN | grep 'name')
        echo '   REQUEST curl -s --header "Authorization: OAuth '$TOKEN'" https://api360.yandex.net/directory/v1/org/'$i'/domains?page='$PAGETOKEN' | jq '
        while [ -n "$(echo $DATA | grep name)" ]; do
                echo '  processing '$i
                echo $DATA | jq >> $NAME/JSON/domains-$i.json
                echo $DATA | jq | grep name | awk '{print $NF}' | sort | uniq | awk -F '"' {'print $2'} >> $FILE.txt
                PAGETOKEN=$(($PAGETOKEN+1))
                DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org/$i/domains?page=$PAGETOKEN | grep 'name')
        done
done
DOMLIST=$(cat $NAME/domains.txt)
ORGLIST=$(cat $NAME/orglist.txt | sed -n '0~2!p')
echo $(date)'-------processing dns-------'
for j in $ORGLIST; do
#uncomment this line if number of organization is more than 1
       DOMLIST=$(cat $NAME/orglist.txt | grep -A1 $j | tail -n 1)
        FILE=$NAME/dns
        for i in $DOMLIST; do
                if [[ -n $(echo $i | egrep '^[а-я]') ]]; then DOMAIN=$(echo $i | idn); else DOMAIN=$i; fi
                DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org/$j/domains/$DOMAIN/dns?page=$PAGETOKEN  | jq)
                PAGETOKEN=1
                while [ -n  "$(echo $DATA | grep recordId)" ]; do
                        echo '   REQUEST curl -s --header "Authorization: OAuth '$TOKEN'" https://api360.yandex.net/directory/v1/org/'$j'/domains/'$DOMAIN'/dns?page='$PAGETOKEN'  | jq'
                        echo '  processing '$i
                        echo $DATA | jq >> $NAME/dns-$i.txt
                        echo $DATA | jq >> $NAME/JSON/dns-$j.json
                        PAGETOKEN=$(($PAGETOKEN+1))
                        DATA=$(curl -s --header "Authorization: OAuth $TOKEN" https://api360.yandex.net/directory/v1/org/$j/domains/$DOMAIN/dns?page=$PAGETOKEN  | jq)
                done
        done
done
echo $(date)'-------COMPLETED-------'
