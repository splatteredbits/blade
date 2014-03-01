$FixturesDir = Join-Path $PSScriptRoot Fixtures
$BladePath = Join-Path $PSScriptRoot ..\Blade\blade.ps1 -Resolve
$markerPath = Join-Path $env:TEMP Test-Blade.marker

function Invoke-Blade($ScriptBlock)
{
    try
    {
        & $ScriptBlock
    }
#    catch { }
    finally
    {
        & (Join-Path -Path $PSScriptRoot -ChildPath '..\Blade\Import-Blade.ps1' -Resolve)
    }
}

function Invoke-BladeOnScript
{
    [CmdletBinding()]
    param(
        $Script
    )

    Invoke-Blade { 
        & $BladePath (Join-Path $FixturesDir "Fixture-$Script.ps1" ) -PassThru -ErrorAction:$ErrorActionPreference
    }
}

function Invoke-BladeOnTest($Script, $Test)
{
    Invoke-Blade {
        & $BladePath (Join-Path $FixturesDir "Fixture-$Script.ps1") -Test $Test -PassThru
    }
}

function Invoke-BladeOnPath($Path)
{
    Invoke-Blade {
        & $BladePath -Path $Path -PassThru
    }
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
    Assert-Equal 1 $Error.Count 'Didn''t get expected errors.'
    Assert-Like $error[0] "Found * error(s) parsing" "didn't find paring errors"
    $error.Clear()
}

function Test-ShouldRunAllTestsUnderAPath
{
    $path = JOin-path $FixturesDir FixturesForPath
    $result = Invoke-BladeOnPath $path
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
    $result = Invoke-BladeOnPath $path
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
    Assert-Equal 3 $result.Length "Not all tests run when teardown fails."
    
    Assert-Equal 'Test-DoNothing' $result[0].Name
    Assert-Equal 'Fixture-TearDownFails' $result[0].FixtureName
    Assert-False $result[0].Passed
    
    Assert-Equal 'Test-DoNothingToo' $result[1].Name
    Assert-Equal 'Fixture-TearDownFails' $result[1].FixtureName
    Assert-False $result[1].Passed
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
    $result = Invoke-BladeOnPath -Path (Join-Path $PSScriptRoot 'Test-NewTempDirectoryTree.ps1')
    Assert-BladeSucceeded $result
    $result | Select-Object -First ($result.Count -1) | ForEach-Object { Assert-True $_.Passed }
}

function Assert-BladeSucceeded
{
    param(
        [object[]]
        $Result
    )

    Assert-Equal 0 $Error.Count
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

    Assert-Like $Error[0].Exception.Message 'Ran * test* with * failure*, * error*, and * ignored in * seconds.'
    [Blade.RunResult]$Result = $Result | Select-Object -Last 1
    Assert-GreaterThan ($Result.Errors.Count + $Result.Failures.Count) 0
}
