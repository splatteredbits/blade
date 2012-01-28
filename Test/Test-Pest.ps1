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
        & $PestPath (Join-Path $FixturesDir "Fixture-$Script.ps1" )
    }
}

function Invoke-PestOnTest($Script, $Test)
{
    Invoke-Pest {
        & $PestPath (Join-Path $FixturesDir "Fixture-$Script.ps1") -Test $Test
    }
}

function Invoke-PestOnPath($Path)
{
    Invoke-Pest {
        & $PestPath -Path $Path
    }
}

function Test-ShouldRunTestsInFile
{
    $result = Invoke-PestOnScript Script
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal '# Fixture-Script #' $result[0] "Didnt' output test fixture header."
    Assert-Equal 'Test-One' $result[1] "Didn't output test one name."
    Assert-Equal 'Test-Two' $result[2] "Didn't output test two name."
    Assert-Report $result[3] -Total 2
}

function Test-ShouldRunJustOneTestInFile
{
    $result = Invoke-PestOnTest Script -Test One
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal '# Fixture-Script #' $result[0] "Didnt' output test fixture header."
    Assert-Equal 'Test-One' $result[1] "Didn't output test name."
    Assert-Report $result[2] -Total 1 
}

function Test-ShouldOnlyRunsFunctionsThatBeginWithTest
{
    $result = Invoke-PestOnScript ScriptWithNoTestFunctions
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Report $result[1]
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
    Assert-Equal '# Fixture-Empty #' $result[0] 'header not output'
    Assert-Report $result[1] 
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
    $expectedLines = @( '# Test-One #', 'Test-One', '# Test-Two #', 'Test-Two' )
    for( $idx = 0; $idx -lt $expectedLines.Count; ++$idx )
    {
        Assert-Equal $expectedLines[$idx] $result[$idx] "Unexpected oUtput at line $idx."
    }
}

function Test-ShouldHandleNoFilesToTestUnderPath
{
    $path = Join-Path $FixturesDir NoTestsHere
    $result = Invoke-PestOnPath $path
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Report $result
}

function Test-ShouldContinueRunningTestsIfTearDownFails
{
    try
    {
        $result = Invoke-PestOnScript TearDownFails
    }
    catch { }
    Assert-Equal 4 $result.Length "Not all tests run when teardown fails."
    Assert-Equal '# Fixture-TearDownFails #' $result[0] 'test header not output'
    Assert-Equal 'Test-DoNothing' $result[1] 'didn''t run first test'
    Assert-Equal 'Test-DoNothingToo' $result[2] 'didn''t run second test'
    Assert-Report $result[3] -Total 2 
}

function Test-ShouldReportIgnoredTests
{
    $result = Invoke-PestOnScript IgnoredTests
    Assert-LastPRocessSucceeded 'pest failed'
    Assert-Equal 2 $result.Length 'Ignored tests run.'
    Assert-Like $result[1] -Ignored 1
}

function Test-ShouldExplicitlyRunIgnoredTest
{
    $result = Invoke-PestOnTest IgnoredTests DoNothing
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal 3 $result.Length 'Ignored test not explicitly run.'
    Assert-Equal 'Ignore-DoNothing' $result[1] 'Ignored test not run'
}

function Test-ShouldReportFailedTests
{
    $result = Invoke-PestOnScript FailingTest
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal -1 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-Equal 3 $result.Length 'Didn''t run test.'
    Assert-Equal 'Test-ShouldFail' $result[1] 'test not run'
    Assert-Report $result[2] -Total 1 -Failures 1
}

function Test-ShouldReportMultipleFailedTests
{
    $result = Invoke-PestOnScript MultipleFailingTests
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal -3 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-Report $result[4] -Total 3 -Failures 3
}

function Test-ShouldReturnFailedExitCodeWhenErrorsEncountered
{
    $result = Invoke-PestOnScript TestWithError
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal 1 $LastExitCode 'Pest didn''t output error code representing number of test with errors.'
    Assert-Equal 3 $result.Length 'Didn''t run test.'
    Assert-Equal 'Test-ShouldHaveError' $result[1] 'test not run'
    Assert-Report $result[2] -Total 1 -Errors 1
}

function Test-ShouldReportMultipleTestsWithErrors
{
    $result = Invoke-PestOnScript WithMultipleErrors
    Assert-LastProcessFailed 'pest succeeded'
    Assert-Equal 3 $LastExitCode 'Pest didn''t output error code representing number of failing tests.'
    Assert-Report $result[4] -Total 3 -Errors 3
}

function Test-ShouldSupportOptionalFixture
{
    $result = Invoke-PestOnScript WithConditionalTests
    Assert-LastProcessSucceeded 'pest failed'
    Assert-Equal 0 $LastExitCode
    Assert-Report $result[1]
}

function Assert-Report($Report, $Total = 0, $Failures = 0, $Errors = 0, $Ignored = 0)
{
    Assert-Match $Report "Ran $Total test\(s\) with $Failures failure\(s\), $Errors error\(s\), and $Ignored ignored in \d+(\.\d+)? second\(s\)." "Didn't get expected output summary."
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