<#
.SYNOPSIS
Imports the Blade module.

.DESCRIPTION
Normally, you shouldn't need to import Blade.  Usually, you'll just call the `blade.ps1` script directly and it will import Blade for you.

If Blade is already imported, it will be removed and then re-imported.

.EXAMPLE
Import-Blade.ps1

Demonstrates how to import the Blade module.
#>
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
