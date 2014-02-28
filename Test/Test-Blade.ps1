<#
.SYNOPSIS 
Tests the blade script.
#>
[CmdletBinding()]
param(
    [alias("n")]
    $TestName = $null
)

$PSScript = $myInvocation.MyCommand.Definition
$PSScriptRoot = Split-Path $PSScript

$FixturesDir = Join-Path $PSScriptRoot Fixtures
$BladePath = Join-Path $PSScriptRoot ..\blade.ps1
$markerPath = Join-Path $env:TEMP Test-Blade.marker

function Setup
{
    $PSScriptRoot = Split-Path $PSScript
    Import-Module (Join-Path $PSScriptRoot .. -Resolve) -Force

    if( Test-Path $markerPath )
    {
        Remove-Item $markerPath
    }
}

function TearDown
{
}

function Invoke-Blade($ScriptBlock)
{
    try
    {
        & $ScriptBlock
    }
#    catch { }
    finally
    {
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot .. -Resolve))
    }
}

function Invoke-BladeOnScript($Script)
{
    Invoke-Blade { 
        & $BladePath (Join-Path $FixturesDir "Fixture-$Script.ps1" ) -PassThru
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
    Assert-LastProcessSucceeded 'blade failed'
    #Assert-Equal '# Fixture-Script #' $result[0] "Didnt' output test fixture header."
    Assert-Equal 'Test-One' $result[0].Name "Didn't output test one name."
    Assert-True $result[0].Passed
    Assert-Equal 'Fixture-Script' $result[0].Fixture
    Assert-Null $result[0].Failure
    Assert-Null $result[0].Exception
    Assert-NotNull $result[0].Duration
    
    Assert-Equal 'Test-Two' $result[1].Name "Didn't output test two name."
    Assert-True $result[1].Passed
    Assert-Equal 'Fixture-Script' $result[1].Fixture
    Assert-Null $result[1].Failure
    Assert-Null $result[1].Exception
    Assert-NotNull $result[1].Duration
}

function Test-ShouldRunJustOneTestInFile
{
    $result = Invoke-BladeOnTest Script -Test One
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Equal 'Test-One' $result.Name
}

function Test-ShouldOnlyRunsFunctionsThatBeginWithTest
{
    $result = Invoke-BladeOnScript ScriptWithNoTestFunctions
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Null $result
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
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Null $result
}

function Test-ShouldHandleSyntaxErrors
{
    try
    {
        $result = Invoke-BladeOnScript SyntaxError
    }
    catch { }
    Assert-Equal 1 $error.Count 'Didn''t get expected errors.'
    Assert-Like $error[0] "Found 1 error(s) parsing" "didn't find paring errors"
    $error.Clear()
}

function Test-ShouldRunAllTestsUnderAPath
{
    $path = JOin-path $FixturesDir FixturesForPath
    $result = Invoke-BladeOnPath $path
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Equal 2 $result.Count
    Assert-Equal 'Test-One' $result[0].Fixture
    Assert-Equal 'Test-One' $result[0].Name
    Assert-Equal 'Test-Two' $result[1].Fixture
    Assert-Equal 'Test-Two' $result[1].Name
}

function Test-ShouldHandleNoFilesToTestUnderPath
{
    $path = Join-Path $FixturesDir NoTestsHere
    $result = Invoke-BladeOnPath $path
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Null $result
}

function Test-ShouldContinueRunningTestsIfTearDownFails
{
    try
    {
        $result = Invoke-BladeOnScript TearDownFails
    }
    catch { }
    Assert-Equal 2 $result.Length "Not all tests run when teardown fails."
    
    Assert-Equal 'Test-DoNothing' $result[0].Name
    Assert-Equal 'Fixture-TearDownFails' $result[0].Fixture
    Assert-True $result[0].Passed
    
    Assert-Equal 'Test-DoNothingToo' $result[1].Name
    Assert-Equal 'Fixture-TearDownFails' $result[1].Fixture
    Assert-True $result[1].Passed
}

function Test-ShouldReportIgnoredTests
{
    $result = Invoke-BladeOnScript IgnoredTests
    Assert-LastPRocessSucceeded 'blade failed'
    Assert-Null $result
}

function Test-ShouldExplicitlyRunIgnoredTest
{
    $result = Invoke-BladeOnTest IgnoredTests DoNothing
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Equal 'Fixture-IgnoredTests' $result.Fixture
    Assert-Equal 'Ignore-DoNothing' $result.Name
    Assert-True $result.Passed
}

function Test-ShouldReportFailedTests
{
    $result = Invoke-BladeOnScript FailingTest
    Assert-LastProcessFailed 'blade succeeded'
    Assert-Equal -1 $LastExitCode 'Blade didn''t output error code representing number of failing tests.'
    Assert-NotNull $result
    Assert-NotNull $result.Failure
    Assert-Like $result.failure '*Test-ShouldFail*'
}

function Test-ShouldReportMultipleFailedTests
{
    $result = Invoke-BladeOnScript MultipleFailingTests
    Assert-LastProcessFailed 'blade succeeded'
    Assert-Equal -3 $LastExitCode 'Blade didn''t output error code representing number of failing tests.'
    Assert-Equal 3 $result.Count
    $result | ForEach-Object { Assert-NotNull $_.Failure }
}

function Test-ShouldReturnFailedExitCodeWhenErrorsEncountered
{
    $result = Invoke-BladeOnScript TestWithError
    Assert-LastProcessFailed 'blade succeeded'
    Assert-Equal 1 $LastExitCode 'Blade didn''t output error code representing number of test with errors.'
    Assert-NotNull $result
    Assert-NotNull $result.Exception
    Assert-Like $result.Exception '*I failed*'
    Assert-Equal 'Test-ShouldHaveError' $result.Name
}

function Test-ShouldReportMultipleTestsWithErrors
{
    $result = Invoke-BladeOnScript WithMultipleErrors
    Assert-LastProcessFailed 'blade succeeded'
    Assert-Equal 3 $LastExitCode 'Blade didn''t output error code representing number of failing tests.'
    Assert-Equal 3 $result.Count
    $result | ForEach-Object { Assert-NotNull $_.Exception }
}

function Test-ShouldSupportOptionalFixture
{
    $result = Invoke-BladeOnScript WithConditionalTests
    Assert-LastProcessSucceeded 'blade failed'
    Assert-Null $result
}

function Test-NewTempDirectoryTree
{
    $result = Invoke-BladeOnPath -Path (Join-Path $PSScriptRoot 'Test-NewTempDirectoryTree.ps1')
    Assert-LastProcessSucceeded 'New-TempDirectoryTree tests failed'
    Assert-NotNull $result
    $result | ForEach-Object { Assert-True $_.Passed }
}


Write-Output "# Test-Blade #"
$testsFailed = 0
$testErrors = 0
$testCount = 0
foreach( $function in (Get-Item function:\Test-*) )
{
    if( $function.Name -eq 'Test-NodeExists' )
    {
        continue
    }
    
    if( -not $TestName -or $function.Name -like "Test-$TestName" )
    {
        $testCount += 1
        $error.Clear()
        Setup
        Write-Output $function.Name
        try
        {
            . $function | Write-Verbose
        }
        catch [Blade.AssertionException] 
        {
            $ex = $_.Exception
            $testsFailed++
            Write-Host "$($ex.Message)`n  at $($ex.PSStackTrace -join "`n  at ")" -ForegroundColor Red
            continue
        }
        catch
        {
            $testErrors++
            for( $idx = 0; $idx -lt $error.Count; ++$idx )
            {
                $err = $error[$idx]
                #Resolve-Error $err
                $errInfo = $err.InvocationInfo
                Write-Host "$($err)`n$($errInfo.PositionMessage.Trim())" -ForegroundColor Red
            }
        }
        finally
        {
            if( Test-Path function:TearDown )
            {
                TearDown
            }
        }
    }
}

Write-Output "Ran $testCount test(s) with $testsFailed failure(s) and $testErrors error(s)."
exit( $testsFailed + $testErrors )