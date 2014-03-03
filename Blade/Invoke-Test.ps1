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

    [Blade.TestResult]$testInfo = New-Object 'Blade.TestResult' $fixture,$function
    Set-CurrentTest $function

    $Global:Error.Clear()

    try
    {
        Invoke-Command -ScriptBlock { 

            if( Test-path function:Start-Test )
            {
                . Start-Test
            }
            elseif( Test-Path function:SetUp )
            {
                . SetUp
            }
        
            try
            {
                if( Test-Path function:$function )
                {
                    . $function 
                }

                $testInfo.Completed()
            }
            finally
            {
                if( Test-Path function:Stop-Test )
                {
                    . Stop-Test
                }
                elseif( Test-Path -Path function:TearDown )
                {
                    . TearDown
                }
            }

        } | ForEach-Object { [void]$testInfo.Output.Add( $_ ) }
    }
    catch [Blade.AssertionException]
    {
        $ex = $_.Exception
        $testInfo.Completed( $ex )
    }
    catch
    {
        $testInfo.Completed( $_ )
    }
    finally
    {
        $Global:Error.Clear()
    }

    $testInfo
}

