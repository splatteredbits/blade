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

function Test-ThrowsShouldFailWhenExceptionNotThrown
{
    $caughtException = $false
    try
    {
        Assert-That { } -Throws ([ApplicationException])
    }
    catch [Blade.AssertionException] 
    {
        $caughtException = $true
        Assert-Match $_.Exception.Message 'did not throw'
    }
}

function Test-ThrowsShouldPasswhenExceptionThrown
{
    Assert-That {
        Assert-That { throw 'Fubar!' } -Throws ([Management.Automation.RuntimeException])
    } -DoesNotThrowException
}

function Test-ThrowsShouldMatchMessage
{
    Assert-That {
        Assert-That { throw 'fubar' } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'fubar'
    } -DoesNotThrowException
}

function Test-ThrowsShouldFailWhenMessageDoesNotMatch
{
    Assert-That {
        Assert-That { throw 'fubar' } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'buzz'
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'Exception message .* doesn''t match'
}

function Test-ThrowsShouldFailIfNotGivenScriptBlock
{
    Assert-That {
        Assert-That 1 -Throws ([ApplicationException])
    } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'must be a ScriptBlock'
}

function Test-DoesNotThrowExceptionShouldFailWhenExceptionThrown
{
    Assert-That {
        Assert-That { throw 'fubar!' } -DoesNotThrowException
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'threw an exception'
}

function Test-DoesNotThrowExceptionShouldPassWhenNoExceptionThrown
{
    Assert-That {
        Assert-That { } -DoesNotThrowException
    } -DoesNotThrowException
}

function Test-DoesNotThrowExceptionShouldFailIfNotGivenScriptBlock
{
    Assert-That {
        Assert-That 1 -DoesNotThrowException
    } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'must be a ScriptBlock'
}

