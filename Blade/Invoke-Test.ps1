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

function Invoke-Test
{
    <#
    .SYNOPSIS
    PRIVATE. Invokes a test from a fixture.

    .DESCRIPTION
    Internal function.  Do not use.
    #>
    [CmdletBinding()]
    param(
        $fixture, 
        $function
    )

    Set-StrictMode -Version 'Latest'

    $testInfo = New-Object 'Blade.TestResult' $fixture,$function
    Set-CurrentTest $function
    $startedAt = Get-Date

    try
    {
        $Global:Error.Clear()

        if( Test-path function:Start-Test )
        {
            . Start-Test | Write-Verbose
        }
        elseif( Test-Path function:SetUp )
        {
            . SetUp | Write-Verbose
        }
        
        if( Test-Path function:$function )
        {
            . $function | ForEach-Object { [void]$testInfo.Output.Add($_) }
        }

        $testInfo.Completed()
    }
    catch [Blade.AssertionException]
    {
        $ex = $_.Exception
        $testInfo.Completed( $ex )
    }
    catch
    {
        if( $_.Exception.Message -eq 'Cannot bind argument to parameter ''Message'' because it is null.' )
        {
            Write-Warning 'It looks like your test is adding a null object to the command pipeline.'
        }
        else
        {
            $testInfo.Completed( $_ )
        }
    }
    finally
    {
        $Global:Error.Clear()
        try
        {
            if( Test-Path function:Stop-Test )
            {
                . Stop-Test | Write-Verbose
            }
            elseif( Test-Path -Path function:TearDown )
            {
                . TearDown | Write-Verbose
            }
        }
        catch
        {
            $testInfo.Completed( $_ )
            Write-Error "An error occured tearing down test '$function': $_"
        }
    }
    $testInfo
}

