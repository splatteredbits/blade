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

$FixturesDir = Join-Path $PSScriptRoot Fixtures
$BladePath = Join-Path $PSScriptRoot ..\Blade\blade.ps1 -Resolve
$markerPath = Join-Path $env:TEMP Test-Blade.marker

function Invoke-Blade
{
    param(
        $Path, 
        $Test
    )

    $powershell = [PowerShell]::Create().AddScript( {
        param(
            $BladePath,
            $Path,
            $Test
        )

        $optionalParams = @{ }
        if( $Test )
        {
            $optionalParams.Test = $TEst
        }
        & $BladePath $Path @optionalParams -PassThru
    } )

    [void] $powershell.AddArgument( $BladePath )
    [void] $powershell.AddArgument( $Path )
    [void] $powershell.AddArgument( $Test )
    $powershell.Invoke()
    $powershell.Streams.Error | ForEach-Object { Write-Error $_ }
    $powershell.Streams.Warning | Write-Warning
    $powershell.Streams.Verbose | Write-Verbose
    $powershell.Dispose()
}

function Invoke-BladeOnScript
{
    [CmdletBinding()]
    param(
        $Script
    )

    Invoke-Blade (Join-Path $FixturesDir "Fixture-$Script.ps1" ) -ErrorAction:$ErrorActionPreference
}

function Invoke-BladeOnTest($Script, $Test)
{
    Invoke-Blade (Join-Path $FixturesDir "Fixture-$Script.ps1") $Test
}

function Test-ShouldRunTestsInFile
{
    $result = Invoke-BladeOnScript Script
    Assert-BladeSucceeded $result
    #Assert-Equal '# Fixture-Script #' $result[0] "Didnt' output test fixture header."
    Assert-Equal 'Test-One' $result[0].Name "Didn't output test one name."
    Assert-True $result[0].Passed
    Assert-Equal 'Fixture-Script' $result[0].FixtureName
    Assert-Null $result[0].Failure
    Assert-Null $result[0].Error
    Assert-NotNull $result[0].Duration
    
    Assert-Equal 'Test-Two' $result[1].Name "Didn't output test two name."
    Assert-True $result[1].Passed
    Assert-Equal 'Fixture-Script' $result[1].FixtureName
    Assert-Null $result[1].Failure
    Assert-Null $result[1].Error
    Assert-NotNull $result[1].Duration
}

function Test-ShouldRunJustOneTestInFile
{
    $result = Invoke-BladeOnTest Script -Test One
    Assert-BladeSucceeded $result
    Assert-Equal 'Test-One' $result[0].Name
}

function Test-ShouldOnlyRunsFunctionsThatBeginWithTest
{
    $result = Invoke-BladeOnScript ScriptWithNoTestFunctions
    Assert-BladeSucceeded $result
}

function Test-ShouldRunSetup
{
    Invoke-BladeOnScript SetupGetsRun
    Assert-FileExists $markerPath
}

function Test-ShouldRunTearDown
{
    Invoke-BladeOnScript TearDownGetsRun
    Assert-FileExists $markerPath
}

function Test-ShouldHandleEmptyTestFixture
{
    $result = Invoke-BladeOnScript Empty
    Assert-BladeSucceeded $result
}

function Test-ShouldHandleSyntaxErrors
{
    try
    {
        $result = Invoke-BladeOnScript SyntaxError -ErrorAction SilentlyContinue
    }
    catch { }
    Assert-Equal 1 $Global:Error.Count 'Didn''t get expected errors.'
    Assert-Like $Global:Error[0] "Found * error(s) parsing" "didn't find paring errors"
}

function Test-ShouldRunAllTestsUnderAPath
{
    $path = JOin-path $FixturesDir FixturesForPath
    $result = Invoke-Blade $path
    Assert-BladeSucceeded $result
    Assert-Equal 3 $result.Count
    Assert-Equal 'Test-One' $result[0].FixtureName
    Assert-Equal 'Test-One' $result[0].Name
    Assert-Equal 'Test-Two' $result[1].FixtureName
    Assert-Equal 'Test-Two' $result[1].Name
}

function Test-ShouldHandleNoFilesToTestUnderPath
{
    $path = Join-Path $FixturesDir NoTestsHere
    $result = Invoke-Blade $path
    Assert-BladeSucceeded $result
}

function Test-ShouldContinueRunningTestsIfTearDownFails
{
    $result = $null
    try
    {
        $result = Invoke-BladeOnScript TearDownFails -ErrorAction SilentlyContinue
    }
    catch { }
    Assert-BladeFailed $result
    Assert-Equal 5 $result.Length "Not all tests run when teardown fails."
    
    Assert-Equal 'Test-DoNothing' $result[0].Name
    Assert-Equal 'Fixture-TearDownFails' $result[0].FixtureName
    Assert-True $result[0].Passed
    
    Assert-Equal 'Test-DoNothing' $result[1].Name
    Assert-Equal 'Fixture-TearDownFails' $result[1].FixtureName
    Assert-False $result[1].Passed
    
    Assert-Equal 'Test-DoNothingToo' $result[2].Name
    Assert-Equal 'Fixture-TearDownFails' $result[2].FixtureName
    Assert-True $result[2].Passed

    Assert-Equal 'Test-DoNothingToo' $result[3].Name
    Assert-Equal 'Fixture-TearDownFails' $result[3].FixtureName
    Assert-False $result[3].Passed
    
}

function Test-ShouldReportIgnoredTests
{
    $result = Invoke-BladeOnScript IgnoredTests
    Assert-BladeSucceeded $result
}

function Test-ShouldExplicitlyRunIgnoredTest
{
    $result = Invoke-BladeOnTest IgnoredTests DoNothing
    Assert-BladeSucceeded $result
    Assert-Equal 'Fixture-IgnoredTests' $result[0].FixtureName
    Assert-Equal 'Ignore-DoNothing' $result[0].Name
    Assert-True $result[0].Passed
}

function Test-ShouldReportFailedTests
{
    $result = Invoke-BladeOnScript FailingTest -ErrorAction SilentlyContinue
    Assert-BladeFailed $result
    Assert-NotNull $result[0].Failure
    Assert-LIke $result[0].Failure.Message '*fail*'
}

function Test-ShouldReportMultipleFailedTests
{
    $result = Invoke-BladeOnScript MultipleFailingTests -ErrorAction SilentlyContinue
    Assert-BladeFailed $result
    Assert-Equal 4 $result.Count
    $result | Select-Object -First 3 | ForEach-Object { Assert-NotNull $_.Failure }
}

function Test-ShouldReturnFailedExitCodeWhenErrorsEncountered
{
    $result = Invoke-BladeOnScript TestWithError -ErrorAction SilentlyContinue
    Assert-BladeFailed $result
    Assert-NotNull $result[0].Error
    Assert-Like $result[0].Error '*I failed*'
    Assert-Equal 'Test-ShouldHaveError' $result[0].Name
}

function Test-ShouldReportMultipleTestsWithErrors
{
    $result = Invoke-BladeOnScript WithMultipleErrors -ErrorAction SilentlyContinue
    Assert-BladeFailed $result
    Assert-Equal 4 $result.Count
    $result | Select-Object -First 3 | ForEach-Object { Assert-NotNull $_.Error }
}

function Test-ShouldSupportOptionalFixture
{
    [Blade.RunResult]$result = Invoke-BladeOnScript WithConditionalTests
    Assert-BladeSucceeded $result
    Assert-Is $result ([Blade.RunResult])
    Assert-Equal 0 $result.Count
}

function Test-NewTempDirectoryTree
{
    $result = Invoke-Blade -Path (Join-Path $PSScriptRoot 'Test-NewTempDirectoryTree.ps1')
    Assert-BladeSucceeded $result
    $result | Select-Object -First ($result.Count -1) | ForEach-Object { Assert-True $_.Passed }
}

function Test-ShouldIncludeTearDownInTestTimings
{
    $fixture = @'
function Start-Test
{
    Start-Sleep -Millisecond 100
}

function Stop-Test
{
    Start-Sleep -Millisecond 100
    # Make sure it tracks the time even if stop-test throws an exception
    throw 'fubar!'
}

function Test-ShouldSleep
{
    Start-Sleep -Millisecond 100
}
'@  | New-TestFixture -Name 'ShouldIncludeTearDownInTestTimings'

    $result = Invoke-Blade -Path $fixture | Select-Object -First 1
    Assert-NotNull $result
    Assert-Is $result ([Blade.TestResult])
    Assert-True ($result.Duration -gt ([timespan]'0:0:0.3')) ('{0}.{1} is shorter than 300 milliseconds' -f $result.Duration,$result.Duration.Milliseconds)
}

function Test-ShouldReturnTestResultForFailedTeardown
{
    $fixture = @'
function Start-Test
{
}

function Stop-Test
{
    throw 'fubar!'
}

function Test-ShouldReturnTestResultForFailedTeardown
{
}
'@  | New-TestFixture -Name 'ShouldIncludeTearDownInTestTimings'

    $result = Invoke-Blade -Path $fixture -ErrorAction SilentlyContinue
    Assert-NotNull $result
    Assert-Equal 3 $result.Count
    $testResult = $result[0]
    $teardownResult = $result[1]
    Assert-Is $teardownResult ([Blade.TestResult])
    Assert-Equal 'Test-ShouldReturnTestResultForFailedTeardown' $teardownResult.Name
    Assert-NotNull $teardownResult.Error
    Assert-Null $teardownResult.Failure
}

function New-TestFixture
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Fixture,

        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    Set-StrictMode -Version 'Latest'

    $path = Join-Path -Path $env:TEMP -ChildPath ('{0}.ps1' -f $Name)
    $Fixture | Set-Content -Path $path
    return $path
}

function Assert-BladeSucceeded
{
    param(
        [object[]]
        $Result
    )

    Assert-Equal 0 $Global:Error.Count
    [Blade.RunResult]$Result = $Result | Select-Object -Last 1
    Assert-Equal 0 $Result.Errors.Count
    Assert-Equal 0 $Result.Failures.Count
}

function Assert-BladeFailed
{
    param(
        [object[]]
        $Result
    )

    Assert-Like $Global:Error[0].Exception.Message 'Ran * test* with * failure*, * error*, and * ignored in * seconds.'
    [Blade.RunResult]$Result = $Result | Select-Object -Last 1
    Assert-GreaterThan ($Result.Errors.Count + $Result.Failures.Count) 0
}
