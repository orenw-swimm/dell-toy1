#Requires -RunAsAdministrator

<#
.SYNOPSIS
    MS SH silent installation script
.DESCRIPTION
    Install msi script to prepare template service
.NOTES
    Version: 1.1
#>
param(
    # Url to SQL Server ISO
    [string] $MsiPath = "",
    [string] $MsiLogs = ""
)

$msiArgs = "/x $MsiPath /qn /norestart /l*v $MsiPath"
Start-Process -Wait -FilePath msiexec -ArgumentList $msiArgs -Verb runAs
