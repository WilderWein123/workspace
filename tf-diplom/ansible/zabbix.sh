#!/bin/bash
#работаем с репозиторием
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
apt update
#устанавливаем пакеты
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server -y
#создаем бд
sudo mysql -uroot -e "create user zabbix@localhost identified with mysql_native_password by 'password123';"
sudo mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;" 
sudo mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost;"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -uroot zabbix
#правим конфиг
echo DBPassword=password123 >> /etc/zabbix/zabbix_server.conf
#рестарт
systemctl restart zabbix-server apache2