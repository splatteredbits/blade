[CmdletBinding(SupportsShouldProcess=$true)]
param(
)

#Requires -Version 3
Set-StrictMode -Version 'Latest'

if( (Get-Module -Name 'Blade') )
{
    Remove-Module 'Blade' -Verbose:$false
}

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Blade.psd1' -Resolve) -Verbose:$false
