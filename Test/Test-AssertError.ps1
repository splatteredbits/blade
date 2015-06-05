# Copyright 2012 - 2015 Aaron Jensen
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

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Blade\Import-Blade.ps1' -Resolve)

function Test-ShouldDetectNoErrors
{
    Write-Error 'Fubar!' -ErrorAction SilentlyContinue
    Assert-That {
        Assert-Error -Count 0
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'Expected ''0'' errors, but found ''1'''
}