Function Set-VMNetworkConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName='DHCP',
                   ValueFromPipeline=$true)]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Static',
                   ValueFromPipeline=$true)]
        [Microsoft.HyperV.PowerShell.VMNetworkAdapter]$NetworkAdapter,

        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName='Static')]
        [String[]]$IPAddress=@(),

        [Parameter(Mandatory=$false,
                   Position=2,
                   ParameterSetName='Static')]
        [String[]]$Subnet=@(),

        [Parameter(Mandatory=$false,
                   Position=3,
                   ParameterSetName='Static')]
        [String[]]$DefaultGateway = @(),

        [Parameter(Mandatory=$false,
                   Position=4,
                   ParameterSetName='Static')]
        [String[]]$DNSServer = @(),

        [Parameter(Mandatory=$false,
                   Position=0,
                   ParameterSetName='DHCP')]
        [Switch]$Dhcp
    )

    $VM = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' | Where-Object { $_.ElementName -eq $NetworkAdapter.VMName } 
    $VMSettings = $vm.GetRelated('Msvm_VirtualSystemSettingData') | Where-Object { $_.VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized' }    
    $VMNetAdapters = $VMSettings.GetRelated('Msvm_SyntheticEthernetPortSettingData') 

    $NetworkSettings = @()
    foreach ($NetAdapter in $VMNetAdapters) {
        if ($NetAdapter.Address -eq $NetworkAdapter.MacAddress) {
            $NetworkSettings = $NetworkSettings + $NetAdapter.GetRelated("Msvm_GuestNetworkAdapterConfiguration")
        }
    }

    $NetworkSettings[0].IPAddresses = $IPAddress
    $NetworkSettings[0].Subnets = $Subnet
    $NetworkSettings[0].DefaultGateways = $DefaultGateway
    $NetworkSettings[0].DNSServers = $DNSServer
    $NetworkSettings[0].ProtocolIFType = 4096

    if ($dhcp) {
        $NetworkSettings[0].DHCPEnabled = $true
    } else {
        $NetworkSettings[0].DHCPEnabled = $false
    }

    $Service = Get-WmiObject -Class "Msvm_VirtualSystemManagementService" -Namespace "root\virtualization\v2"
    $setIP = $Service.SetGuestNetworkAdapterConfiguration($VM, $NetworkSettings[0].GetText(1))

    if ($setip.ReturnValue -eq 4096) {
        $job=[WMI]$setip.job 

        while ($job.JobState -eq 3 -or $job.JobState -eq 4) {
            start-sleep 1
            $job=[WMI]$setip.job
        }

        if ($job.JobState -eq 7) {
            write-host "Success"
        }
        else {
            $job.GetError()
        }
    } elseif($setip.ReturnValue -eq 0) {
        Write-Host "Success"
    }
}

#if ((Get-Content C:\scripts\trigger.txt) -eq 0) {break}
echo "Creating snapshot..."
$sourcevm = "msk-s0-rpa4"
#$sourcevm = "msk-s0-rpa4-3"
Checkpoint-VM -name $sourcevm
$names=@(
"msk-s0-rpa4-1"
#"msk-s0-rpa4-2"
#"msk-s0-rpa4-3",
#"msk-s0-rpa4-4",
#"msk-s0-rpa4-5",
#"msk-s0-rpa4-6",
#"msk-s0-rpa4-7"
#"msk-s0-rpa4-8"
)
foreach ($item in $names) {
    write-host $item
    write-host "Stopping VM "$item
    stop-vm -name $item -TurnOff
    write-host "Copiyng HDD to VM "$item
	$temp=-join('D:\Hyper-V\Virtual Hard Disks\',$sourcevm,'.vhdx')
    $target=-join("D:\Hyper-V\Virtual Hard Disks\",$item,".vhdx")
    Copy-Item $temp $target
    write-host "starting VM and dropping network "$item
    Get-VMNetworkAdapter -VMName $item | Disconnect-VMNetworkAdapter
    start-vm $item
    $temp=((Get-VMNetworkAdapter -VMName $item).IpAddresses).Count
        while ($temp -eq 0) {
        write-host "waiting VM "$item" for network"
        Start-Sleep 1
        $temp=((Get-VMNetworkAdapter -VMName $item).IpAddresses).Count
        }
    write-host "adding network parameters for machine "$item
    $temp=(Get-VM -VmName $item | select -ExpandProperty Notes).Split("`t")[1]
    write-host "enabling network "$item
    Connect-VMNetworkAdapter -VMName $item -SwitchName virtsw
    start-sleep 30
    while (Get-VMNetworkAdapter -VMName $item | Where-Object {$_.IpAddresses -like "*169.254*"}) {
        write-host "tuning network settings machine "$item
        Get-VMNetworkAdapter -VMName $item | Set-VMNetworkConfiguration -IPAddress $temp -Subnet 255.255.255.0 -DNSServer 172.16.160.19 -DefaultGateway 172.16.160.1
        start-sleep 5
    }
    write-host " machine "$item" cloning compete"

}
echo "Removing snapshot..."
Remove-VMSnapshot -VMName $sourcevm
