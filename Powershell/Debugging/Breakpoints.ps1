#Use breakpoints
$s=Get-Service wuauserv
$s | Stop-Service -WhatIf

#in debugger type h for help

#set a break point from the console
Set-PSBreakpoint -Line 3 -Script .\Breakpoints.ps1