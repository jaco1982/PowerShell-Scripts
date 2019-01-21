# Veeam Repo Sync #

function Get-DateDiff {
    param ( 
        [CmdletBinding()] 
        [parameter(Mandatory=$true)]
        [datetime]$date1, 
        [parameter(Mandatory=$true)]
        [datetime]$date2
    ) 
    if ($date2 -gt $date1){$diff = $date2 - $date1}
    else {$diff = $date1 - $date2}
    $diff.TotalSeconds
} 

function SetExecPolicy {
    $CurrentPolicy = Get-ExecutionPolicy
    If ($CurrentPolicy -ne 'RemoteSigned')
    {
        WRITE-HOST "The current execution policy is set to $CurrentPolicy - this is a bad thing!"
        WRITE-HOST "I'll try to set the execution policy to 'RemoteSigned' - just a sec."
        SET-EXECUTIONPOLICY RemoteSigned
        RETURN
    }
}

function LoadVeeamDLL 
{
    WRITE-HOST "Now loading the Veeam PowerShell Snap-in."
    Add-PSSnapin -Name VeeamPSSnapIn
}

SetExecPolicy
LoadVeeamDLL

$tt=0;
$veeamrepo = New-Object system.Collections.ArrayList
Get-VBRBackupRepository | foreach {$veeamrepo.Insert( $tt, $_.name); $tt++}
$u=0;
WRITE-HOST "The number of found Veeam repositories:" $veeamrepo.count
If ($veeamrepo.count -gt 0){

    for ($k=0; $k -le $veeamrepo.count – 1; $k++){
    $jname=$veeamrepo[$k]
    WRITE-HOST "The repository name is:" $jname
                try {
                Get-VBRBackupRepository -Name $jname | Sync-VBRBackupRepository
                }
                catch {
                WRITE-HOST "Error syncing repository."
                error = 1
                }
                }
}
