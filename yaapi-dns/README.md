## Скрипт по резервному копированию DNS-записей яндекс

# Технические подробности

В несколько запросов скрипт формирует несколько переменных.
Запрос 1 - получение списка организаций из Я360.
Запрос 2 - получение списка доменов по каждой организации из Я360.
Запрос 3 - получение списка DNS по каждому домену. 

В рабочей директории скрипта создается структура каталогов:
1. 20240101/data
2. 20240101/data/JSON

Директория 1 предназначена для дисгностики или просмотра администратором.
orglist.txt - список организаций по аккаунту. Первая строка ID организации, вторая имя организации
domains.txt - список доменов организации.
dns-DOMAINNAME.txt - список DNS записей по опеределнному домену ввиде JSON.

Директория 2 - это выданные Яндекс API запросы, предназначенные для автоматической заугрзки. ПРОЦЕСС НЕИССЛЕДОВАН!!!

Представленные в репозитории 2 файла имеют несколько различные назначения:
| имя файла | описание | пример |
| ------ | ----- | ----- |
| yaapi-dns-single.sh | предназначен для аккаунтов с множетсвом доменов в одной организации | wiseadvicedns |
| yaapi-dns-multi.sh | предназначен для акаунтов со схемой "1 организация = 1 домен" | wiseadvicedns2@wiseadvicedns2.yaconnect.com |

# Запуск

yaaapi-dns-single.sh <TOKEN> <path-to-work-dir>
yaaapi-dns-multi.sh <TOKEN> <path-to-work-dir>

| имя аккаунта | сслыка на токен | текущий путь (msk-s0-pbs01p) |
| ------ | ----- | ----- |
| wiseadvicedns | https://pwd.wagroup.ru/index.php?page=items&group=10&id=1240 | /scripts/dns/1/ |
| wiseadvicedns2@wiseadvicedns2.yaconnect.com | https://pwd.wagroup.ru/index.php?page=items&group=10&id=1241 | /scripts/dns/2/ |

# файл systemd-timer
```
[Unit]
Description=Logs some system statistics to the systemd journal
Requires=yaapi-dns1.service

[Timer]
Unit=yaapi-dns1.service
OnCalendar=*-*-* 00:23:00

[Install]
WantedBy=timers.target
```
# файл systemd
```
[Unit]
Description=Logs some system statistics to the systemd journal
Requires=myMonitor.service

[Timer]
Unit=myMonitor.service
OnCalendar=*-*-* 00:23:00

[Install]
WantedBy=timers.target
root@msk-s0-pbs01p:/var/lib/systemd/deb-systemd-helper-enabled/timers.target.wants# cat yaapi-dns1.service
[Unit]
Description=Logs system statistics to the systemd journal
Wants=yaapi-dns1.service.timer

[Service]
Type=oneshot
ExecStart=/scripts/dns/1/scripts.sh

[Install]
WantedBy=multi-user.target
```
Для дальнейшей регистрации файлов как демона скореектировать имена и пути в файлах и выполнить команды:
```
systemctl daemon-deload
systemctl link ./yaapi-dns1.service
systemctl enable yaapi-dns1.service
systemctl start yaapi-dns1.service
```

# Логирование

По-умолчанию логирование реализовывается в STDOUT. Скрипт логирует стадии выполнения (забор данных по организациям, запрос данных по доменам и запрос данных по DNS), логирует дату начала и дату окончания выполнения. 
В случае запуска через crontab вывод лога можно реализовать перенаправлением ( script>log.txt ), в случае запуска через systemd лог будет автоматически помещен в SYSLOG с именем соответствующего юнита. 
