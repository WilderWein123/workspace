[nginx]
%{ for ip in nginxes ~}
${ip}
%{ endfor ~}

[zabbix]
${zabbix}

[kibana]
${kibana}

[elastic]
${elastic}
