<#

.SYNOPSIS 

Tests the pest script.
#>
[CmdletBinding()]
param(
    [alias("n")]
    $TestName = $null
)

$PSScript = $myInvocation.MyCommand.Definition
$PSScriptRoot = Split-Path $PSScript

$FixturesDir = Join-Path $PSScriptRoot Fixtures
$PestPath = Join-Path $PSScriptRoot ..\pest.ps1
$markerPath = Join-Path $env:TEMP Test-Pest.marker

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

function Invoke-Pest($ScriptBlock)
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

function Invoke-PestOnScript($Script)
{
    Invoke-Pest { 
        & $PestPath (Join-Path $FixturesDir "Fixture-$Script.ps1" ) -PassThru
    }
}

function Invoke-PestOnTest($Script, $Test)
{
    Invoke-Pest {
        & $PestPath (Join-Path $FixturesDir "Fixture-$Script.ps1") -Test $Test -PassThru
    }
}

function Invoke-PestOnPath($Path)
{
    Invoke-Pest {
        & $PestPath -Path $Path -PassThru
    }
}

function Test-ShouldRunTestsInFile
{
    $result = Invoke-PestOnScript Script
    Assert-LastProcessSucceeded 'pest failed'
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
    $result = Invoke-PestOnTest Script -Test One
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal 'Test-One' $result.Name
}

function Test-ShouldOnlyRunsFunctionsThatBeginWithTest
{
    $result = Invoke-PestOnScript ScriptWithNoTestFunctions
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Null $result
}

function Test-ShouldRunSetup
{
    Invoke-PestOnScript SetupGetsRun
    Assert-FileExists $markerPath
}

function Test-ShouldRunTearDown
{
    Invoke-PestOnScript TearDownGetsRun
    Assert-FileExists $markerPath
}

function Test-ShouldHandleEmptyTestFixture
{
    $result = Invoke-PestOnScript Empty
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Null $result
}

function Test-ShouldHandleSyntaxErrors
{
    try
    {
        $result = Invoke-PestOnScript SyntaxError
    }
    catch { }
    Assert-Equal 1 $error.Count 'Didn''t get expected errors.'
    Assert-Like $error[0] "Found 1 error(s) parsing" "didn't find paring errors"
    $error.Clear()
}

function Test-ShouldRunAllTestsUnderAPath
{
    $path = JOin-path $FixturesDir FixturesForPath
    $result = Invoke-PestOnPath $path
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal 2 $result.Count
    Assert-Equal 'Test-One' $result[0].Fixture
    Assert-Equal 'Test-One' $result[0].Name
    Assert-Equal 'Test-Two' $result[1].Fixture
    Assert-Equal 'Test-Two' $result[1].Name
}

function Test-ShouldHandleNoFilesToTestUnderPath
{
    $path = Join-Path $FixturesDir NoTestsHere
    $result = Invoke-PestOnPath $path
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Null $result
}

function Test-ShouldContinueRunningTestsIfTearDownFails
{
    try
    {
        $result = Invoke-PestOnScript TearDownFails
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
    $result = Invoke-PestOnScript IgnoredTests
    Assert-LastPRocessSucceeded 'pest failed'
    Assert-Null $result
}

function Test-ShouldExplicitlyRunIgnoredTest
{
    $result = Invoke-PestOnTest IgnoredTests DoNothing
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal 'Fixture-IgnoredTests' $result.Fixture
    Assert-Equal 'Ignore-DoNothing' $result.Name
    Assert-True $result.Passed
}

function Test-ShouldReportFailedTests
{
    $result = Invoke-PestOnScript FailingTest
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal -1 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-NotNull $result
    Assert-NotNull $result.Failure
    Assert-Like $result.failure '*Test-ShouldFail*'
}

function Test-ShouldReportMultipleFailedTests
{
    $result = Invoke-PestOnScript MultipleFailingTests
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal -3 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-Equal 3 $result.Count
    $result | ForEach-Object { Assert-NotNull $_.Failure }
}

function Test-ShouldReturnFailedExitCodeWhenErrorsEncountered
{
    $result = Invoke-PestOnScript TestWithError
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal 1 $LastExitCode 'Pest didn''t output error code representing number of test with errors.'
    Assert-NotNull $result
    Assert-NotNull $result.Exception
    Assert-Like $result.Exception '*I failed*'
    Assert-Equal 'Test-ShouldHaveError' $result.Name
}

function Test-ShouldReportMultipleTestsWithErrors
{
    $result = Invoke-PestOnScript WithMultipleErrors
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal 3 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-Equal 3 $result.Count
    $result | ForEach-Object { Assert-NotNull $_.Exception }
}

function Test-ShouldSupportOptionalFixture
{
    $result = Invoke-PestOnScript WithConditionalTests
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Null $result
}


Write-Output "# Test-Pest #"
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
        catch [Pest.AssertionException] 
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