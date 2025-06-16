#Script to clean out all the content the Temp share and then re-create the users folders.
#This share is mapped to VDI's and RDS sessions as T: from \\ausradio.net.au\Shared\AUS\Aquira Temp\%username%\
#This script requires the role\function for AD module \ Powershell be installed
# 
# v1.00 - Denis Markwell / 16/06/2025

#Variables
$WorkingPath = "G:\UserTemp\"
$LogPath = ("$WorkingPath\_logs\CleanupJob_"+([DateTime]::Now.ToString("yyyyMMdd-HHmmss"))+".log")
$UserGroup = "AVD Shares - Temp Drive"

#Logging
if (-NOT (Test-Path $WorkingPath\_logs)) { New-Item -Name "_Logs" -Path $WorkingPath -ItemType Directory }
Add-Content $LogPath -Value "$(Get-Date) - Starting Clean up and folder creation task"

#Delete everything except the _Log folder
$FolderItems = Get-ChildItem -Path $WorkingPath
foreach ($FolderItem in $FolderItems) {
    If ($FolderItem.Name -ne "_logs") {
        Remove-Item ("$WorkingPath"+"$FolderItem") -force -Recurse -Verbose -ErrorAction SilentlyContinue
        Add-Content $LogPath -Value "$(Get-Date) - Deleted $WorkingPath$FolderItem"
        }
    }

#Create new user folders
$ADGroupMembers = Get-ADGroup -Identity $UserGroup | Get-ADGroupMember
ForEach ($ADGroupMember in $ADGroupMembers) {
    New-Item -Name $ADGroupMember.SamAccountName -Path $WorkingPath -ItemType Directory
    Add-Content $LogPath -Value "$(Get-Date) - Creating New folder for User $ADGroupMember.name"
    }
