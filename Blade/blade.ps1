<#
.SYNOPSIS
Runs Blade tests in a file or set of directories.

.DESCRIPTION
Blade is a simple testing framework, inspired by NUnit.  It reads in all the files under a given path (or paths), and opens each file that matches the `Test-*` pattern.  It will then execute the tests in that file.  Blade tests are functions that that use the `Test` verb in their name, i.e. whose name match the `Test-*` pattern.

When executing the tests in a file, Blade does the following:

 * Calls the `Start-TestFixture` function (if one is defined)
 * Executes each test.  For each test, Blade calls the `Start-Test` function (if defined), followed by the test, followed by the `Stop-Test` function (if defined).
 * Calls the `Stop-TestFixture` function (if one is defined)

Output is captured and written to verbose output.

.EXAMPLE
.\blade Test-MyScript.ps1

Will run all the tests in the `Test-MyScript.ps1` script.

.EXAMPLE
.\blade Test-MyScript.ps1 -Test MyTest

Will run the `MyTest` test in the `Test-MyScript.ps1` test script.

.EXAMPLE
blade .\MyModule

Will run all tests in the files which match the `Test-*.ps1` wildcard in the .\MyModule directory.

.EXAMPLE
blade .\MyModule -Recurse

Will run all test in files which match the `Test-*.ps1` wildcard under the .\MyModule directory and its sub-directories.

#>

[CmdletBinding(DefaultParameterSetName='SingleScript')]
param(
    [Parameter(Mandatory=$true,Position=0)]
    [string[]]
    # The paths to search for tests.  All files matching Test-*.ps1 will be run.
    $Path,
    
    [string[]]
    # The individual test in the script to run.  Defaults to all tests.
    $Test,
    
    [Switch]
    # Return objects for each test run.
    $PassThru,
    
    [Switch]
    # Recurse through directories under `$Path` to find tests.
    $Recurse
)

#Requires -Version 3
$ErrorActionPreference = 'Stop'

if( (Get-Module -Name 'Blade') )
{
    Remove-Module 'Blade'
}
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Blade.psd1' -Resolve)

$modules = @{ }
Get-Module | % { $modules[$_.Name] = $true }

Set-TestVerbosity $VerbosePreference

function Exit-Blade($exitCode = 0)
{
    exit($exitCode)
}

function Get-FunctionsInFile($testScript)
{
    Write-Verbose "Loading test script '$testScript'."
    $testScriptContent = Get-Content "$testScript"
    if( -not $testScriptContent )
    {
        return @()
    }

    $errors = [Management.Automation.PSParseError[]] @()
    $tokens = [System.Management.Automation.PsParser]::Tokenize( $testScriptContent, [ref] $errors )
    if( $errors -ne $null -and $errors.Count -gt 0 )
    {
        Write-Error "Found $($errors.count) error(s) parsing '$testScript'."
        Exit-Blade -1 
    }
    
    Write-Verbose "Found $($tokens.Count) tokens in '$testScript'."
    
    $functions = New-Object System.Collections.ArrayList
    $atFunction = $false
    for( $idx = 0; $idx -lt $tokens.Count; ++$idx )
    {
        $token = $tokens[$idx]
        if( $token.Type -eq 'Keyword'-and $token.Content -eq 'Function' )
        {
            $atFunction = $true
        }
        
        if( $atFunction -and $token.Type -eq 'CommandArgument' -and $token.Content -ne '' )
        {
            Write-Verbose "Found function '$($token.Content).'"
            [void] $functions.Add( $token.Content )
            $atFunction = $false
        }
    }
    
    return $functions.ToArray()
}

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}

function New-TestInfoObject
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the test fixture.
        $Fixture,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the test.
        $Name
    )
    $props =  @{ 
                    Fixture = $Fixture; 
                    Name = $Name ; 
                    Passed = $false; 
                    Failure = $null;
                    Exception = $null; 
                    Duration = $null; 
                    PipelineOutput = @();
                }
    
    New-Object PsObject -Property $props
}

function Invoke-Test($fixture, $function)
{
    $testInfo = New-TestInfoObject -Fixture $fixture -Name $function
    Set-CurrentTest $function
    $startedAt = Get-Date
    $output = @()
    try
    {
        
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
            $testInfo.Passed = $true
            . $function | ForEach-Object { $output += $_ }
        }
    }
    catch [Blade.AssertionException]
    {
        $ex = $_.Exception
        $testInfo.Passed = $false
        $testInfo.Failure = "{0}`n  at {1}" -f $ex.Message,($ex.PSStackTrace -join "`n  at ")
    }
    catch
    {
        if( $_.Exception.Message -eq 'Cannot bind argument to parameter ''Message'' because it is null.' )
        {
            Write-Warning 'It looks like your test is adding a null object to the command pipeline.'
        }
        else
        {
            $innerException = $_.Exception
            while( $innerException.InnerException )
            {
                $innerException = $innerException.InnerException
            }
            $testInfo.Passed = $false
            $testInfo.Exception = "{0}: {1}{2}" -f $innerException.GetType().FullName,$innerException.Message,$error[0].InvocationInfo.PositionMessage
        }
    }
    finally
    {
        if( $output )
        {
            $testInfo.PipelineOutput = $output
        }
        $error.Clear()
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
            Write-Host "An error occured tearing down test '$function': $_" -ForegroundColor Red
            $testInfo.Passed = $false
            $error.Clear()
        }
    }
    $testInfo.Duration = (Get-Date) - $startedAt 
    $testInfo
}

$getChildItemParams = @{ }
if( $Recurse )
{
    $getChildItemParams.Recurse = $true
}

$testScripts = @( Get-ChildItem $Path Test-*.ps1 @getChildItemParams )
if( $testScripts -eq $null )
{
    $testScripts = @()
}

$error.Clear()
$testsRun = 0
$testsFailed = 0
$testsIgnored = 0
$testErrors = 0
$TestScript = $null
$TestDir = $null
$startedAt = Get-Date

$results = $null
$testScripts | 
    ForEach-Object {
        $testCase = $_
        $TestScript = (Resolve-Path $testCase.FullName).Path
        $TestDir = Split-Path -Parent $testCase.FullName 
        
        $testModuleName =  [System.IO.Path]::GetFileNameWithoutExtension($testCase)

        $functions = Get-FunctionsInFile $testCase.FullName |
                        Where-Object { $_ -match '^(Test|Ignore)-(.*)$' } |
                        Where-Object { 
                            if( $PSBoundParameters.ContainsKey('Test') )
                            {
                                return $Test | Where-Object { $Matches[2] -like $_ } 
                            }

                            if( $Matches[1] -eq 'Ignore' )
                            {
                                Write-Warning ("Skipping ignored test '{0}'." -f $_)
                                $testsIgnored++
                                return $false
                            }

                            return $true
                        }
        @('Start-TestFixture','Start-Test','Setup','TearDown','Stop-Test','Stop-TestFixture') |
            ForEach-Object { Join-Path -Path 'function:' -ChildPath $_ } |
            Where-Object { Test-Path -Path $_ } |
            Remove-Item
        
        . $testCase.FullName
        try
        {
            if( Test-Path -Path function:Start-TestFixture )
            {
                . Start-TestFixture | Write-Verbose
            }

            foreach( $function in $functions )
            {

                if( -not (Test-Path function:$function) )
                {
                    continue
                }
                
                Invoke-Test $testModuleName $function
            }

            if( Test-Path -Path function:Stop-TestFixture )
            {
                try
                {
                    . Stop-TestFixture | Write-Verbose
                }
                catch
                {
                    Write-Host ("An error occured tearing down test fixture '{0}': {1}" -f $testCase.Name,$_) -ForegroundColor Red
                    $result = New-TestInfoObject -Fixture $testModuleName -Name 'Stop-TestFixture'
                    $result.Exception = $_
                    $result
                    $error.Clear()
                }                
            }
        }
        finally
        {
            foreach( $function in $functions )
            {
                if( $function -and (Test-Path function:$function) )
                {
                    Remove-Item function:\$function
                }
            }
            
            # if we don't unload any modules loaded by the test, they get cached by PowerShell 
            # and subsequent runs of the test script won't reload the updated module.
            Get-Module | % {
                if( -not $modules.ContainsKey( $_.Name ) )
                {
                    Remove-Module $_.Name -ErrorAction SilentlyContinue
                }
            }
        }        
    } | 
    Tee-Object -Variable 'results' |
    Where-Object { -not $PassThru -and -not $_.Passed } |
    Format-List Fixture,Name,Duration,Failure,Exception

if( $results )
{
    $testsRun = @( $results ).Count
    $failedTests = @( $results | Where-Object { -not $_.Passed } )
    $testsFailed = $failedTests.Count
    $testErrors = @( $results | Where-Object { $_.Exception -ne $null } ).Count
}
else
{
    $testsRun = $testsFailed = $testErrors = 0
}
$timeTook = (Get-Date) - $startedAt
Write-Host "Ran $testsRun test(s) with $testsFailed failure(s), $testErrors error(s), and $testsIgnored ignored in $($timeTook.TotalSeconds) second(s)."


if( $PassThru )
{
    $results
}

$exitCode = (-$testsFailed)
if( $testErrors -gt 0 )
{
    $exitCode = $testErrors
}
Exit-Blade $exitCode