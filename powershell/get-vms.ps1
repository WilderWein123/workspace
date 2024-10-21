
#
# Version 20210416
# Updated work with 1+ logical drives. Fixed snapshot searcher
#
#
$list=(get-vm)
$list
$outfile="C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\index.html"
'<html><body><form>'| out-file $outfile
$env:COMPUTERNAME | out-file $outfile -Append
'<table><table border="1"><tr><th>Имя ВМ</th><th>Кол-во vCPU</th><th>Память, MB</th><th colspan=3>Описание</th><th>Виртуальные диски</th><th>Суммарный размер</th></tr>' | out-file $outfile -append
$totalcpu=0
$totalmemory=0
$totaldisks=0
foreach ($item in $list) {
    $a=(get-vm $item.Name | where-object {$_.Path -NotLike "*Replica*"} | select Name,ProcessorCount,@{Name="Memory123";Expression={($_.MemoryStartup / 1Mb)}},Notes)
    $drive_sum=0

    foreach ($item2 in $a) {
    if ($item.State -eq "Running") {
        -join("<tr><td>",$item2.Name)| out-file $outfile -Append
        if ((get-vm $item2.Name).ReplicationMode -eq "Primary") {
            -join (" реплицирована на ",(Get-VMReplication $item2.Name | select -ExpandProperty ReplicaServer))| out-file $outfile -Append
            }
        -join("</td><td>",$item2.ProcessorCount,"</td><td>",$item2.Memory123,"</td><td colspan=3>",$item2.Notes,"</td><td>")| out-file $outfile -Append
        $totalcpu+=$item2.ProcessorCount
        $totalmemory+=$item2.Memory123
        foreach ($item3 in $item2) {
            get-vm $item2.Name | select vmid | get-vhd -ErrorAction SilentlyContinue | select @{Name="Disk";Expression={$_.Path.Split("\")[-1]}},@{Name="Size";Expression={[math]::Round($_.Size / 1Gb)}} | fl | out-file $outfile -Append
            }
        foreach ($item3 in get-vm $item2.Name | select vmid | get-vhd -ErrorAction SilentlyContinue)
            {$drive_sum+=[math]::Round($item3.Size)}
        "</td><td>" | out-file $outfile -Append
        [math]::Round($drive_sum / 1Gb) | out-file $outfile -Append
        "</td></tr>" | out-file $outfile -Append
        $totaldisks+=($drive_sum)
    }
    }
        
}
$replicatedsize=(get-vm | where-object {$_.Path -like "*Replica*"} | select vmid | get-vhd -ErrorAction SilentlyContinue | Measure-Object Size -Sum).Sum / 1Gb
if ($replicatedsize) {-join("<tr><td><b>Реплицированных данных,ГБ</b></td><td></td><td><td colspan=3></td><td></td><td>",$replicatedsize,"</td></tr>")| out-file $outfile -Append}
#calculating snapshoots size
$hyperv_drives=(get-vm | select vmid | get-vhd -ErrorAction SilentlyContinue | select -ExpandProperty Path | % {($PSItem).Split(":")[0]} | sort -Unique)
$snapshots=0
#checking for snapshot and their size
foreach ($item in $hyperv_drives) {
    $snapshots+=([math]::Round((Get-ChildItem $item":" -Recurse -File | Where-Object {$_.Name -like "*.avhdx*"} | Measure-Object -Property Length -Sum | select -expandproperty Sum) / 1Gb))
}
if ($snapshots) {-join("<tr><td><b>Контрольные точки,ГБ</b></td><td></td><td><td colspan=3></td><td></td><td>",$snapshots,"</td></tr>")| out-file $outfile -Append}
#checking for powered off machines and their size
$poweredoff=(get-vm | where {($_.State -eq "Off") -and ($_.ReplicationMode -eq "None")}| select vmid | get-vhd -ErrorAction SilentlyContinue | Measure-Object Size -Sum).Sum / 1Gb 
if ($poweredoff) {-join("<tr><td><b>Отключенные виртуальные машины</b></td><td></td><td><td colspan=3></td><td></td><td>")| out-file $outfile -Append
    $poweredoff | out-file $outfile -Append 
    "</td>"| out-file $outfile -Append
    }
-join("<tr><td><b>Виртуальные машины</b></td><td>",$totalcpu,"</td><td>",$totalmemory,"<td colspan=3></td><td></td><td>")| out-file $outfile -Append
#get-vm | where {($_.State -eq "Off") -and ($_.ReplicationMode -eq "None")}
[math]::Round($totaldisks / 1Gb)| out-file $outfile -Append 
"</td>"| out-file $outfile -Append
$hardcpu=(Get-WmiObject -Class Win32_Processor | select NumberOfLogicalProcessors | Measure-Object -Property NumberOfLogicalProcessors -Sum | select Sum)
$hardmemory=(Get-WMIObject win32_ComputerSystem | select TotalPhysicalMemory)
#calculating drives where virtual machines are 
$harddisks=(Get-PartitionSupportedSize -DriveLetter (get-vm | select vmid | get-vhd -ErrorAction SilentlyContinue | select -ExpandProperty Path | % {($PSItem).Split(":")[0]} | sort -Unique) | Measure-Object SizeMax -Sum | select -ExpandProperty Sum)
-join("<tr><td><b>Ресурсов хоста</b></td><td>",$hardcpu.Sum,"</td><td>",[math]::Round($hardmemory.TotalPhysicalMemory / 1Mb),"<td colspan=3></td><td></td><td>")| out-file $outfile -Append
[math]::Round($harddisks / 1Gb)| out-file $outfile -Append
"</td>"| out-file $outfile -Append
$leftcpu=$hardcpu.Sum-$totalcpu
$leftmemory=[math]::Round($hardmemory.TotalPhysicalMemory / 1Mb)-$totalmemory
$leftdisks=[math]::Round($harddisks / 1Gb)-[math]::Round($totaldisks / 1Gb)-$replicatedsize-$poweredoff-$snapshots
$leftcpu
$leftmemory
$leftdisks
-join("<tr><td><b>Остаток ресурсов</b></td><td>",$leftcpu,"</td><td>",$leftmemory,"<td colspan=3></td><td></td><td>")| out-file $outfile -Append
$leftdisks| out-file $outfile -Append

"</td>"| out-file $outfile -Append
"</form></body></html>" | out-file $outfile -Append
$snapshots
#,ProcessorCount,MemoryMaximum