#
#version 20231114
#last commit - added deleting recovered journal mechanism
#
$ErrorActionPreference = "Stop"
'BEGIN' | out-file C:\scripts\logclear\zabbix.txt -Append
#where is 1c installed
$clusterpath="D:\Program Files\1cv8\srvinfo\reg_1541\"
$7zipbin="C:\Program Files\7-zip\7z.exe"
#days from today to keep logs
$days=-1424
#days from today to keep unarchived logs
$days_unarchived=-31
#begin
$basedirlist=(Get-ChildItem -Directory $clusterpath -Exclude s*).BaseName
$modifycount=0
#creating directory
$workdir=-join("C:\scripts\logclear\",($(Get-Date -Format "yyyyMMdd")))
New-Item -ItemType Directory $workdir -ErrorAction SilentlyContinue
#making a copy of config
Copy-Item $clusterpath\1CV8Clst.LST $clusterpath\cleaner.LST -force
#header for DBU
$basedirlist
"<HTML><BR>" | out-file $workdir\dbu.txt -Append
-join("Отчет по файлам журнала сервера ",$env:COMPUTERNAME,"<BR>") | out-file $workdir\dbu.txt -Append
"Следующие базы нуждаются в изменении режима логирования <BR><BR>" | out-file $workdir\dbu.txt -Append
foreach ($item in $basedirlist) {
#converting ID to basename (reading LST file)
    $basename=((((Get-ChildItem (-join($clusterpath,"cleaner.LST")) |Select-String -Pattern (-join("{",$item))) | select -first 1) -split ",")| select -first 2 | select -last 1) -replace('"','')
    $fullpath=-join($clusterpath,$item,"\1Cv8Log")
#checking no log folder
    $searchstring=(get-date (get-date).AddDays(-1) -UFormat "%Y%m%d")
    $temppath=-join($fullpath,"\1Cv8Log\1Cv8.lgd")
if ($basename) {
    $modifycurrent=0
    if ((get-item $temppath -ErrorAction SilentlyContinue).Count -eq 1) {
        write-host (get-item $fullpath\1cv8.lgd -ErrorAction SilentlyContinue).Count
        -join("LOGFILES need modifiying ",$basename," ID ",$item," REASON Требуется перевод лога в старый формат") | out-file $workdir\log.txt -Append
        -join("<b>",$basename,"</b> -- Требуется перевод ЖР в старый формат<br>") | out-file $workdir\dbu.txt -Append
        write-host (-join($basename,"<br> REASON Требуется перевод лога в старый формат <br>"))
#searching for fault logs

        }
        else {
        $lastfile=(Get-childitem $fullpath -filter *.lgp -ErrorAction SilentlyContinue | Sort-Object -Property CreationTime | select -Last 1  | select CreationTime,LastWriteTime)
        $lastfile2=-join($fullpath,"\",$searchstring,"*.lgp")
#searching for fault logs - main
        $temppath=-join($fullpath,"\*.lgp")
        (get-item $temppath -ErrorAction SilentlyContinue).Count
        if ((get-item $temppath -ErrorAction SilentlyContinue).Count -eq 0) {
            write-host (get-item $temppath -ErrorAction SilentlyContinue).Count
            -join("LOGFILES need modifiying ",$basename," ID ",$item," REASON Файл журнала отсутствует последние 90 дней (база не используется?)") | out-file $workdir\log.txt -Append
            -join("<b>",$basename,"</b> -- Файл ЖР отсутствует последние 90 дней (база не используется?)<br>") | out-file $workdir\dbu.txt -Append
            write-host (-join($basename,"<br> REASON Файл журнала отсутствует последние 90 дней (база не используется?) <br>"))

            }
            else {
                write-host $lastfile
                (($lastfile.LastWriteTime)-($lastfile.CreationTime)).Days
                if (((($lastfile.LastWriteTime)-($lastfile.CreationTime)).Days -ne 0)) {

                    -join("LOGFILES need modifiying ",$basename," ID ",$item," REASON Отсутствует настройка обрезки периода") | out-file $workdir\log.txt -Append
                    -join("<b>",$basename,"</b> -- не настроена ежедневная ротация ЖР <br>") | out-file $workdir\dbu.txt -Append
                    write-host (-join($basename,"<br> REASON Отсутствует настройка обрезки периода <br>"))
                    $modifycount+=1
                }
#breaking loop if logs found
                }
        }
    $needarchiving=1
    }
if ($needarchiving=1) {
'CONFIG FOUND' | out-file C:\scripts\logclear\zabbix.txt -Append
#searching for very old files
    -join("Checking files for delete for base",$basename) | out-file $workdir\log.txt -Append
    $file_log=(Get-ChildItem $fullpath -Filter *.lgp -ErrorAction SilentlyContinue |where-object {$_.LastWriteTime -lt (get-date).AddDays($days)} -ErrorAction SilentlyContinue)
    -join("     ",($file_log).Count," OLD LOG FILES FOUND") | out-file $workdir\log.txt -Append
    $file_arc=(Get-ChildItem $fullpath -Filter *.7z -ErrorAction SilentlyContinue |where-object {$_.LastWriteTime -lt (get-date).AddDays($days)} -ErrorAction SilentlyContinue)
    -join("     ",($file_arc).Count," OLD ARCHIVE FILES FOUND") | out-file $workdir\log.txt -Append
    Get-ChildItem $fullpath -Filter *.7z -ErrorAction SilentlyContinue |where-object {$_.LastWriteTime -lt (get-date).AddDays($days)} | Remove-Item
#searching for archiving files
    $file_log=(Get-ChildItem $fullpath -Filter *.lgp -ErrorAction SilentlyContinue |where-object {$_.LastWriteTime -lt (get-date).AddDays($days_unarchived)})
    -join("     ",($file_log).Count," LOG FILES FOUND FOR ARCHIVING") | out-file $workdir\log.txt -Append
    if ($file_log) {'ARC FOUND' | out-file C:\scripts\logclear\zabbix.txt -Append}
#compressing it
    foreach ($item2 in $file_log) {
    $log1=$fullpath+"\"+$item2
    $log1
    $lgx1=$fullpath+"\"+$item2.BaseName+".lgx"
    $lgx1
    $lgall1=$fullpath+"\"+$item2.BaseName+".*"
    $arc1=$fullpath+"\"+$item2+".7z"
    $arc1
#first archiving files without delete source
    $args=-join (" u `"",$fullpath,"\",$item2,".7z`""," `"",$lgall1,"`""," -mx9 -mmt1")
    -join("          ",($(Get-Date -Format "yyyyMMdd HHMM"))," Compressing logfile ",$item2," from base ",$basename," ID ",$item) | out-file $workdir\log.txt -Append
    start-process $7zipbin -ArgumentList $args -NoNewWindow -Wait
#copying attributes
    Get-ItemProperty $log1 | select LastWriteTime | Set-ItemProperty $arc1
#removing files
    remove-item $log1 -ErrorAction SilentlyContinue
    remove-item $lgx1 -ErrorAction SilentlyContinue
    }
}
}
"</HTML>" | out-file $workdir\dbu.txt -Append
#final reporting to zabbix
$result1=((Get-Content C:\scripts\logclear\zabbix.txt | findstr CONFIG).Count)
$result2=((Get-Content $workdir\log.txt) | findstr Checking).Count
'0' | out-file C:\scripts\logclear\zabbix.txt
if ($result1=1) {'1' | out-file C:\scripts\logclear\zabbix.txt}
if ($result1=$result2) {'1' | out-file C:\scripts\logclear\zabbix.txt}
#emailing to user
$secpasswd = ConvertTo-SecureString "Nen483H4b2sf" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("server@intelis.loc", $secpasswd)
write-host $modifycount
$subj=-join("Изменение режима логирования баз ",$env:COMPUTERNAME) 
-join("<BR><BR><BR>1.	Инструкция по настройке ЖР: https://cf.9958258.ru/pages/viewpage.action?pageId=65997662<BR>") | out-file $workdir\dbu.txt -Append
-join("2.	Если база больше не нужна, то ее нужно удалить из кластера и написать на oit@wiseadvice.ru для удаления с сервера СУБД.") | out-file $workdir\dbu.txt -Append
#uncomment next line, if its youright server
#if ((([Int] (Get-Date).DayOfWeek) -eq 2) -and ($modifycount -ne 0)) {Send-MailMessage -SmtpServer ex.9958258.ru -Credential $cred -From 'server@wiseadvice.ru' -To "yarastov@wiseadvice.ru","ityarastov@yandex.ru","admin@wiseadvice.ru" -Subject $subj -Body (get-content $workdir\dbu.txt | Out-String) -Bodyashtml -Encoding ([Text.Encoding]::GetEncoding("utf-8"))}
#uncomment next line, if its dbu server
if ($modifycount -ne 0) {Send-MailMessage -SmtpServer ex.9958258.ru -Credential $cred -From 'server@wiseadvice.ru' -To "admin1c@wiseadvice.ru","admin@wiseadvice.ru" -Subject $subj -Body (get-content $workdir\dbu.txt | Out-String) -Bodyashtml -Encoding ([Text.Encoding]::GetEncoding("utf-8"))}
#uncomment next line, if you're Seregin
#Send-MailMessage -SmtpServer ex.9958258.ru -Credential $cred -From 'server@wiseadvice.ru' -To seregin@wiseadvice.ru -Subject $subj -Body (get-content $workdir\dbu.txt | Out-String) -Bodyashtml -Encoding ([Text.Encoding]::GetEncoding("utf-8"))
