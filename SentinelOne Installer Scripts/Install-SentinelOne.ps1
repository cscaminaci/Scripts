<#	
	.NOTES
	===========================================================================
	 Created on:   	6/7/2022 23:54
	 Created by:   	Christopher Scaminaci AKA Ceej the MSP Automator
	 Organization: 	MSPautomator.com
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A simple install script for SentinelOne that is universal, accepting a
		parameter for the site token.
#>

param
(
	[parameter(Mandatory = $true)]
	[String]
	$Token
)

Write-Host "Attempting to create scratch directories...."
try
{
	New-Item -Path "C:\" -Name "TEMP" -ItemType "directory" -ErrorAction Stop
}
catch
{
	$StopError = $_.Exception.Message
	Write-Host "Can't create scratch directory - error is: $StopError"
}

Write-Host "Scratch space configured successfully....attempting to download SentinelOne..."

$Url1 = 'https://URL.TO.S1.EXECUTABLE'
$File1 = 'C:\TEMP\' + $(Split-Path -Path $Url1 -Leaf)

try
{
	Invoke-WebRequest -Uri $Url1 -OutFile $File1 -ErrorAction Stop
}
catch
{
	$StopError = $_.Exception.Message
	Write-Host "No worky - error is: $StopError"
	$script:ExitCode = 0
}

Write-Host "Download successful...terminating..."

msiexec /i 'C:\TEMP\SentinelOne.msi' /q /NORESTART SITE_TOKEN=$Token
