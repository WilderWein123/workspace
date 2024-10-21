#
#
Param (
    [string]$disknumber
)

if (!($disknumber)) {
$a=@()
$data=@()
#parsing licenses
$output=("list volume"|C:\scripts\diskpart.exe | findstr Volume)
foreach ($row in $output) {
     if (!$row.Contains("Volume ###")) {
        if ($row -match "\s\s(Volume\s\d)\s+([A-Z])\s+(.*)\s\s(NTFS|FAT)\s+(Mirror|RAID-5|Stripe|Spiegel|Spiegelung|Übergreifend|Spanned)\s+(\d+)\s+(..)\s\s([A-Za-z]*\s?[A-Za-z]*)(\s\s)*.*") {
            $a+=-join($matches[01],",",$matches[5],",",$matches[8])
            $raidnum=($matches[01]).Split()[1]
        }
    }      
}
#generating json
 write-host '{'
 write-host ' "data":['
 $count=$a.Count
 foreach ($item in $a) {
    write-host '  {'
    write-host '   "{#DISKNAME}": "' -NoNewline
    write-host $item.Split(",")[0] -NoNewline
    write-host '",'
    write-host '   "{#DISKVOLUME}": "' -NoNewline
    write-host "ARRAY" -NoNewline
    write-host '",'
    write-host '   "{#DISKSTATUS}": "' -NoNewline
    write-host ($item.Split(",")[2]).TrimEnd(" ") -NoNewline
    write-host '",'
    write-host '   "{#DISKMODEL}": "' -NoNewline
    write-host $item.Split(",")[1] -NoNewline
    write-host '",'
    write-host '   "{#DISKSERIAL}": "ARRAY"'
    write-host '}'
    write-host ','
        }


$a=@()
'((@"' | out-file C:\scripts\script.ps1
-join("select volume ",$raidnum) | out-file C:\scripts\script.ps1 -append
'detail volume' | out-file C:\scripts\script.ps1 -append
'"@' | out-file C:\scripts\script.ps1 -append
'))|C:\scripts\diskpart.exe | findstr Disk' | out-file C:\scripts\script.ps1 -append
$output=powershell -f C:\scripts\script.ps1
#generating json
$count=$output.Count
$count=$count-2
foreach ($row in $output) {
    if (!$row.Contains("###") -and !$row.Contains("Microsoft")) {
        $hdd=$row.Split()[3]
        $status=$row.Split()[7]
        '((@"' | out-file C:\scripts\script2.ps1
        -join("select disk ",$hdd) | out-file C:\scripts\script2.ps1 -append
        'detail disk' | out-file C:\scripts\script2.ps1 -append
        '"@' | out-file C:\scripts\script2.ps1 -append
        ')|C:\scripts\diskpart.exe)' | out-file C:\scripts\script2.ps1 -append
        $output=powershell.exe -file C:\scripts\script2.ps1
        $model=$output[10]
        $serial=$output[11]
        $volume=-join(($output[28]).Split()[2]," ",($output[28]).Split()[3])
#        $a+=-join($hdd,",",$status,",",$model,",",$serial)
#generation json
    write-host '  {'
    write-host '   "{#DISKNAME}": "' -NoNewline
    write-host "Disk"$hdd -NoNewline
    write-host '",'
    write-host '   "{#DISKVOLUME}": "' -NoNewline
    write-host $volume -NoNewline
    write-host '",'
    write-host '   "{#DISKSTATUS}": "' -NoNewline
    write-host $status -NoNewline
    write-host '",'
    write-host '   "{#DISKMODEL}": "' -NoNewline
    write-host $model -NoNewline
    write-host '",'
    write-host '   "{#DISKSERIAL}": "' -NoNewline
    write-host $serial -NoNewline
    write-host '"}'
    $count=$count-1
    if ($count -eq 0) {
        write-host ' ]'
        write-host '}'
    }
    if ($count -ne 0) {
        write-host ' ,'
        }

        }
}
}


if ($disknumber -like "*Disk*") {
        $a="list disk" | C:\scripts\diskpart.exe
        if (($a | Select-String -Pattern $disknumber) -like "*Online*") {write-host 1} else {write-host 0}
        break
}
    if ($disknumber -like "*Volume*") {
        $a="list volume" |C:\scripts\diskpart.exe
        if (($a | Select-String -Pattern $disknumber) -like "*Healthy*") {write-host 1} else {write-host 0}
        break
        }
