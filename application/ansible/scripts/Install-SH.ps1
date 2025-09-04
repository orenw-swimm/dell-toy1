#Requires -RunAsAdministrator

<#
.SYNOPSIS
    MS SH silent installation script
.DESCRIPTION
    Install msi script to prepare template service
.NOTES
    Version: 1.1
#>
[CmdletBinding()]
param(
    # Url to SQL Server ISO
    [string] $MsiPath,
    [string] $MsiLogs,
    [string] $InstallDir,
    [string] $ServiceName
)

$msiArgs = "/i $MsiPath /qn /norestart /l*v $MsiLogs HOST=Service ADDLOCAL=Service ConnectionSetupMethod=Manual DEVICENAME=$ServiceName INSTALLFOLDER=$InstallDir"
echo $msiArgs
Start-Process -Wait -FilePath msiexec -ArgumentList $msiArgs -Verb runAs