function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

ipn1=10.1.18.20
ipn2=10.1.18.21
ipn3=10.1.18.23
ipn4=10.1.18.24
ipn5=10.1.18.25
ipn6=10.1.18.26
ipn7=10.1.18.27

cpun1=48
ramn1=256
hddn1=4400
cpun2=56
ramn2=256
hddn2=7800
cpun3=56
ramn3=256
hddn3=7800
cpun4=48
ramn4=256
hddn4=4400
cpun5=56
ramn5=256
hddn5=4400
cpun6=48
ramn6=256
hddn6=4400
cpun7=56
ramn7=256
hddn7=4400

pm_html=/tmp/pm.html
echo > $pm_html

# Формируем заголовок html
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' > $pm_html
echo '<html>'                                                                                                 >> $pm_html
echo ' <head>'                                                                                                >> $pm_html
echo '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">'                                  >> $pm_html
echo '  <title>Распределение ВМ. Proxmox.</title>'                                                            >> $pm_html
echo ' </head>'                                                                                               >> $pm_html
echo ' <body>'                                                                                                >> $pm_html
echo ' <table width="100%" border="1" cellpadding="4" cellspacing="0">'                                       >> $pm_html
echo '  <tr>'                                                                                                 >> $pm_html
echo '      <td rowspan="2" bgcolor="#DCDCDC">Наименование Node (VM/CT)</td>'                                 >> $pm_html
echo '      <td rowspan="2" bgcolor="#DCDCDC">ip, ответственный, описание</td>'                               >> $pm_html
echo '      <td bgcolor="#DCDCDC" colspan="6">Выделенные ресурсы</td>'                                        >> $pm_html
echo '  </tr>'                                                                                                >> $pm_html
echo '  <tr>'                                                                                                 >> $pm_html
echo '      <td bgcolor="#DCDCDC">vCPU</td>'                                                                  >> $pm_html
echo '      <td bgcolor="#DCDCDC">RAM, GB</td>'                                                               >> $pm_html
echo '      <td bgcolor="#DCDCDC" colspan="4">HDD, GB</td>'                                                   >> $pm_html
echo '  </tr>'                                                                                                >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node01</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn1}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun1}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn1}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn1}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node01/lxc/* /etc/pve/nodes/node01/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun1=$(($cpun1 - $cpu))
    ramn1=$(($ramn1 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn1=$(($hddn1 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun1}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn1}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn1}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node02</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn2}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun2}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn2}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn2}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node02/lxc/* /etc/pve/nodes/node02/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun2=$(($cpun2 - $cpu))
    ramn2=$(($ramn2 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn2=$(($hddn2 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun2}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn2}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn2}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node03</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn3}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun3}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn3}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn3}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node03/lxc/* /etc/pve/nodes/node03/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun3=$(($cpun3 - $cpu))
    ramn3=$(($ramn3 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn3=$(($hddn3 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun3}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn3}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn3}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node04</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn4}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun4}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn4}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn4}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node04/lxc/* /etc/pve/nodes/node04/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun4=$(($cpun4 - $cpu))
    ramn4=$(($ramn4 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn4=$(($hddn4 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun4}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn4}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn4}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node05</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn5}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun5}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn5}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn5}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node05/lxc/* /etc/pve/nodes/node05/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun5=$(($cpun5 - $cpu))
    ramn5=$(($ramn5 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn5=$(($hddn5 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun5}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn5}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn5}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node06</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn6}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun6}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn6}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn6}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node06/lxc/* /etc/pve/nodes/node06/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun6=$(($cpun6 - $cpu))
    ramn6=$(($ramn6 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn6=$(($hddn6 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun6}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn6}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn6}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html

echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#ADD8E6">node07</td>'                 >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ipn7}'</td>'              >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${cpun7}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6">'${ramn7}'</td>'             >> $pm_html
echo '      <td bgcolor="#ADD8E6" colspan="4">'${hddn7}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html

for i in `find /etc/pve/nodes/node07/lxc/* /etc/pve/nodes/node07/qemu-server/* 2>/dev/null`
 do
    vname=$(grep name: $i | awk '{print $2}')
    comm=$(grep "#" $i); comm=$(urldecode $comm | grep -v '^$' | cut -c 2- | sed 's/ #/, /g')
    core=$(grep -m1 "cores: " $i| awk '{print $2}'); if [ -z $core ]; then core=1; fi
    socket=$(grep -m1 "sockets: " $i| awk '{print $2}'); if [ -z $socket ]; then socket=1; fi
    cpu=$(($core * $socket))
    ram=$(grep -m1 "memory: " $i| awk '{print $2/1024}')
    hdd0=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 1)')
    hdd1=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 2)')
    hdd2=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 3)')
    hdd3=$(grep size $i| grep -v iso | sort -k2 | sed 's/.*size=//g'| tr -d "G" | awk -F "," '{print $1}' | awk '(NR == 4)')
    echo '  <tr>'                    >> $pm_html
    echo '      <td>' $vname '</td>' >> $pm_html
    echo '      <td>' $comm '</td>'  >> $pm_html
    echo '      <td>' $cpu '</td>'   >> $pm_html
    echo '      <td>' $ram '</td>'   >> $pm_html
    echo '      <td>' $hdd0 '</td>'  >> $pm_html
    echo '      <td>' $hdd1 '</td>'  >> $pm_html
    echo '      <td>' $hdd2 '</td>'  >> $pm_html
    echo '      <td>' $hdd3 '</td>'  >> $pm_html
    echo '  </tr>'                   >> $pm_html
    cpun7=$(($cpun7 - $cpu))
    ramn7=$(($ramn7 - $ram))
    if [ -z $hdd0 ]; then hdd0=0; fi
    if [ -z $hdd1 ]; then hdd1=0; fi
    if [ -z $hdd2 ]; then hdd2=0; fi
    if [ -z $hdd3 ]; then hdd3=0; fi
    hddn7=$(($hddn7 - $hdd0 - $hdd1 - $hdd2 - $hdd3))
done

echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr>'                                                  >> $pm_html
echo '      <td bgcolor="#FFEBCD">Остаток ресурсов</td>'       >> $pm_html
echo '      <td bgcolor="#FFEBCD"></td>'                       >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${cpun7}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD">'${ramn7}'</td>'             >> $pm_html
echo '      <td bgcolor="#FFEBCD" colspan="4">'${hddn7}'</td>' >> $pm_html
echo '  </tr>'                                                 >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html
echo '  <tr><td colspan="8"></td></tr>'                        >> $pm_html


# Закрываем html
echo ' </table>' >> $pm_html
echo '</body>'   >> $pm_html
echo '</html>'   >> $pm_html