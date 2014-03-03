<#
.SYNOPSIS
Copies the latest version of Blade to a directory.
#>
# Copyright 2012 - 2014 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The path to deploy Blade to.
    $Path
)

#Requires -Version 3
Set-StrictMode -Version 'Latest'

if( -not (Test-Path -Path $Path -PathType Container) )
{
    New-Item -Path $Path -ItemType 'Directory' -Force
}

Get-ChildItem -Path $Path | Remove-Item -Recurse

Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Blade') | Copy-Item -Destination $Path -Container
