Add-PSSnapin VeeamPSSnapin

$VBRBackups = Get-VBRBackup | Sort-Object JobName
$csvContents = @()


#We are interested in: 
#JobID,JobName,LastPointCreation(LastRun),VMCount,TypeToString,DirPath,Repository,Host,RepositoryHost,StartTime,RunAfter
# 

    $ID = ""
    $BackupName = ""
    $Type = ""
    $LastRun = ""
    $VMCount = ""
    $Type = ""
    $Path = ""
    $RepoName = ""
    $RepoHost = ""
    $RP = ""
    $BackupHost = ""
    $RunAfter = ""
    $StartTime = ""
    $RunAfter = ""
    $LocalRemote = ""

        #Create CSV

        Foreach($Backup in $VBRBackups)
        {
            #Check if local Job
            $ID = $Backup.Id
            $Job = Get-VBRJob -Name $Backup.JobName
            
            if($Job -eq $Null)
            { #If the name field is blank, it means this is a remote backup, not a local job
            # We are interested in: 
            # -JobID,-JobName,-LastPointCreation(LastRun),-VMCount,-TypeToString,-DirPath,-Repository,-Host,-RepositoryHost,
            # *StartTime,*RunAfter,*RestorePoints

                
                $ID = $Backup.ID
                $BackupName = $Backup.Name
                $LastRun = $Backup.LastPointCreationTime
                $VMCount = $Backup.VmCount
                $Type = $Backup.TypeToString
                $Path = $Backup.DirPath
                $LocalRemote = "Offsite"
                
                #Get repository and host
                $RepoName = Get-VBRBackupRepository | Where-Object {$_.ID -eq $Backup.RepositoryId}
                $RepoHost = Get-VBRServer | Where-Object {$_.ID -eq $RepoName.HostID}
                $RepoName = $RepoName.Name
                $RepoHost = $RepoHost.Name

                #Get Backup host
                $BackupHostServer = Get-VBRServer | Where-Object {$_.ID -eq $Backup.JobTargetHostId}
                $BackupHost = $BackupHostServer.Name

                #Get Repository host
                
                
            }
            if($Job -ne $Null)
            { #If the name field is not blank, it means this is a local job
            # We are interested in: 
            # -JobID,-JobName,-LastPointCreation(LastRun),-VMCount,-TypeToString,-DirPath,-Repository,-Host,-RepositoryHost,
            # -StartTime,-RunAfter,-RestorePoints
                
                #Get basic info
                $ID = $Job.ID
                $BackupName = $Job.Name
                $Type = $Job.TypeToString
                $RP = $Job.GetOptions().backupstorageoptions.retainCycles
                $BackupHostServer = Get-VBRServer | Where-Object {$_.ID -eq $Job.TargetHostId}
                $BackupHost = $BackupHostServer.Name
                $LocalRemote = "Local"
                               
                #Get run after job
                $RunAfter = Get-VBRJob | Where-Object {$_.ID -eq $Job.PreviousJobIdInScheduleChain}
                $RunAfter = $RunAfter.Name
                
                #Get last run time and path
                #$Backup = Get-VBRBackup | Where{$_.JobName -eq $Job.Name}
                $LastRun = $Backup.LastPointCreationTime#.ToDateTime()
                $Path = $Backup.DirPath
                
                #Get VMs in Job
                $Objects = $Job.GetObjectsInJob()
                $VMCount = $Objects.Count

                #Get Repository
                $RepoTarget = $Job.FindTargetRepository()
                $RepoName = $RepoTarget.Name
                $RepoHostServer = Get-VBRServer | Where-Object {$_.ID -eq $RepoTarget.HostId}
                $RepoHost = $RepoHostServer.Name

                #Get start time
                $StartTime = $Job.ScheduleOptions.StartDateTimeLocal

                #if($RunAfter -ne ""){$StartTime = ""}
                
            }

            #Add line to CSV
            $row = New-Object System.Object
            $row | Add-Member -MemberType NoteProperty -Name "ID" -Value $ID
            $row | Add-Member -MemberType NoteProperty -Name "Name" -Value $BackupName
            $row | Add-Member -MemberType NoteProperty -Name "Local" -Value $LocalRemote
            $row | Add-Member -MemberType NoteProperty -Name "LastRun" -Value $LastRun
            $row | Add-Member -MemberType NoteProperty -Name "VMCount" -Value $VMCount
            $row | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
            $row | Add-Member -MemberType NoteProperty -Name "Path" -Value $Path
            $row | Add-Member -MemberType NoteProperty -Name "Repo" -Value $RepoName
            $row | Add-Member -MemberType NoteProperty -Name "RepoHost" -Value $RepoHost
            $row | Add-Member -MemberType NoteProperty -Name "Host" -Value $BackupHost
            $row | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $StartTime
            $row | Add-Member -MemberType NoteProperty -Name "RunAfter" -Value $RunAfter
            $row | Add-Member -MemberType NoteProperty -Name "RestorePoints" -Value $RP

            $row

            $csvContents += $row

            $ID = ""
            $BackupName = ""
            $LocalRemote = ""
            $LastRun = ""
            $VMCount = ""
            $TypeToString = ""
            $Path = ""
            $RepoName = ""
            $RepoHost = ""
            $BackupHost = ""
            $StartTime = ""
            $RunAfter = ""
            $RP = ""

        }

        $csvContents | Export-CSV C:\Users\Administrator.new\Desktop\Data.csv
    
    
