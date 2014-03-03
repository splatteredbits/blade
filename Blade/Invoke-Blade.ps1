
function Invoke-Blade
{
    <#
    .SYNOPSIS
    Runs Blade tests in a file or set of directories.

    .DESCRIPTION
    Blade is a simple testing framework, inspired by NUnit.  It reads in all the files under a given path (or paths), and opens each file that matches the `Test-*` pattern.  It will then execute the tests in that file.  Blade tests are functions that that use the `Test` verb in their name, i.e. whose name match the `Test-*` pattern.

    When executing the tests in a file, Blade does the following:

     * Calls the `Start-TestFixture` function (if one is defined)
     * Executes each test.  For each test, Blade calls the `Start-Test` function (if defined), followed by the test, followed by the `Stop-Test` function (if defined).
     * Calls the `Stop-TestFixture` function (if one is defined)

    Blade will return `Blade.TestResult` objects for all failed tests and a final `Blade.RunResult` object summarizing the results.  Use the `PassThru` switch to also get `Blade.TestResult` objects for passing tests.

    You can access the `Blade.RunResult` object from the last test run via the global `LASTBLADERESULT` variable.

    .LINK
    about_Blade

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

    Set-StrictMode -Version 'Latest'

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
    $testsIgnored = 0
    $TestScript = $null
    $TestDir = $null

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
            if( -not $functions )
            {
                return
            }

            @('Start-TestFixture','Start-Test','Setup','TearDown','Stop-Test','Stop-TestFixture') |
                ForEach-Object { Join-Path -Path 'function:' -ChildPath $_ } |
                Where-Object { Test-Path -Path $_ } |
                Remove-Item
        
            . $testCase.FullName
            try
            {
                if( Test-Path -Path 'function:Start-TestFixture' )
                {
                    . Start-TestFixture | Write-Verbose
                }

                foreach( $function in $functions )
                {

                    if( -not (Test-Path -Path function:$function) )
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
                        Write-Error ("An error occured tearing down test fixture '{0}': {1}" -f $testCase.Name,$_)
                        $result = New-Object 'Blade.TestResult' $testModuleName,'Stop-TestFixture'
                        $result.Finished( $_ )
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
            }        
        } | 
        Tee-Object -Variable 'results' |
        Where-Object { $PassThru -or -not $_.Passed } 

    $global:LASTBLADERESULT = New-Object 'Blade.RunResult' ([Blade.TestResult[]]$results), $testsIgnored
    if( $LASTBLADERESULT.Errors -or $LASTBLADERESULT.Failures )
    {
        Write-Error $LASTBLADERESULT.ToString()
    }
    $global:LASTBLADERESULT

}