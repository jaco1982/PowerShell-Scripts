# (c)2019, Jaco du Plessis
# Released under GNU GPL
# This contains a list of quick, custom disk utilities

Function Get-DiskSpace {
    
    param (
        [Parameter(Mandatory=$true)][string]$Name
    )
    
    Get-WmiObject -Class win32_logicalDisk -ComputerName $Name | Select-Object pscomputername, deviceid, @{Name="Free GB"; Expression={[math]::round($_.freespace/1GB, 2)}}, @{Name="Total GB"; Expression={[math]::round($_.size/1GB, 2)}}    

}



