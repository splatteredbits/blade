
& (Join-Path -Path $PSScriptRoot -ChildPath '..\Blade\Import-Blade.ps1' -Resolve)
$tempDir = New-TempDirectory -Prefix $PSCommandPath
$outFile = $null

function Start-TestFixture
{
}

function Stop-TestFixture
{
    Remove-Item -Path $tempDir -Recurse
}

function Start-Test
{
    $outFile = Join-Path -Path $tempDir -ChildPath ([IO.Path]::GetRandomFileName())
}

function Test-ShouldExportEmptyResult
{
    $result = New-Object 'Blade.RunResult' 'ShouldExportEmptyResult',([Blade.TestResult[]]@()),0
    Assert-ShouldExportRunResult $result
}

function Test-ShouldExportIgnoredTests
{
    $result = New-Object 'Blade.RunResult' 'ShouldExportIgnoredTests',([Blade.TestResult[]]@()),1
    Assert-ShouldExportRunResult $result
}

function Test-ShouldExportPositiveResults
{
    $1_1 = New-Object 'Blade.TestResult' 'Fixture1','Test1'
    $1_2 = New-Object 'Blade.TestResult' 'Fixture1','Test2'

    $2_1 = New-Object 'Blade.TestResult' 'Fixture2','Test1'
    $2_2 = New-Object 'Blade.TestResult' 'Fixture2','Test2'

    @( $1_1, $1_2, $2_1, $2_2 ) | ForEach-Object { Start-Sleep -Milliseconds (Get-Random -Minimum 1 -Maximum 100); $_.Completed() }

    $result = New-Object 'Blade.RunResult' 'ShouldExportPositiveResults',([Blade.TestResult[]]@($1_1, $1_2, $2_1, $2_2)),0
    Assert-ShouldExportRunResult $result
}

function Test-ShouldExportErrors
{
    $1_1 = New-Object 'Blade.TestResult' 'Fixture1','Test1'
    $1_2 = New-Object 'Blade.TestResult' 'Fixture1','Test2'

    $2_1 = New-Object 'Blade.TestResult' 'Fixture2','Test1'
    $2_2 = New-Object 'Blade.TestResult' 'Fixture2','Test2'

    @( $1_1, $2_1, $2_2 ) | ForEach-Object { Start-Sleep -Milliseconds (Get-Random -Minimum 1 -Maximum 100); $_.Completed() }

    $1_2.Completed( (New-Object 'Blade.AssertionException' 'Fubar',(Get-PSCallStack)) )

    $result = New-Object 'Blade.RunResult' 'ShouldExportErrors',([Blade.TestResult[]]@($1_1, $1_2, $2_1, $2_2)),0
    Assert-ShouldExportRunResult $result
}

function Test-ShouldExportFailures
{
    $1_1 = New-Object 'Blade.TestResult' 'Fixture1','Test1'
    $1_2 = New-Object 'Blade.TestResult' 'Fixture1','Test2'

    $2_1 = New-Object 'Blade.TestResult' 'Fixture2','Test1'
    $2_2 = New-Object 'Blade.TestResult' 'Fixture2','Test2'

    @( $1_1, $2_1, $2_2 ) | ForEach-Object { Start-Sleep -Milliseconds (Get-Random -Minimum 1 -Maximum 100); $_.Completed() }

    Write-Error 'fubar' -ErrorAction SilentlyContinue
    $1_2.Completed( $Error[0] )
    $Error.Clear()

    $result = New-Object 'Blade.RunResult' 'ShouldExportFailures',([Blade.TestResult[]]@($1_1, $1_2, $2_1, $2_2)),0
    Assert-ShouldExportRunResult $result
}

function Get-RunResultXml
{
    $resultXml = [xml](Get-Content -Path $outFile -Raw)
    Assert-NotNull $resultXml
    return $resultXml.'test-results'
}

function Assert-ShouldExportRunResult
{
    param(
        [Parameter(Mandatory=$true)]
        [Blade.RunResult]
        $RunResult
    )

    $RunResult | Export-RunResultXml -FilePath $outFile
    Assert-NoError
    Assert-FileExists $outFile

    $docRoot = Get-RunResultXml
    $env = $docRoot.environment
    Assert-Equal (Get-Module -Name 'Blade').Version $env.'blade-version'
    Assert-Equal $PSVersionTable.CLRVersion $env.'clr-version'
    Assert-Equal $PSVersionTable.PSVersion $env.'powershell-version'
    Assert-Equal ([Environment]::OSVersion).VersionString $env.'os-version'
    Assert-Equal ([Environment]::OSVersion).Platform $env.'platform'
    Assert-Equal (Get-Location).Path $env.'cwd'
    Assert-Equal ([Environment]::MachineName) $env.'machine-name'
    Assert-Equal ([Environment]::UserName) $env.'user'
    Assert-Equal ($env:USERDOMAIN) $env.'user-domain'
    
    $culture = $docRoot.'culture-info'
    Assert-NotNull $culture
    Assert-Equal (Get-Culture).Name $culture.'current-culture'
    Assert-Equal (Get-UICulture).Name $culture.'current-uiculture'

    Assert-Equal $RunResult.Name $docRoot.Attributes['name'].Value
    Assert-Equal $docRoot.Attributes['not-run'].Value '0'
    Assert-Equal $docRoot.Attributes['inconclusive'].Value '0'
    Assert-Equal $docRoot.Attributes['ignored'].Value $RunResult.IgnoredCount
    Assert-Equal $docRoot.Attributes['skipped'].Value '0'
    Assert-Equal $docRoot.Attributes['invalid'].Value '0'
    Assert-Equal $docRoot.Attributes['date'].Value ( '{0:yyyy-MM-dd}' -f (Get-Date))
    Assert-Match $docRoot.Attributes['time'].Value ( '^{0:HH:mm}:\d\d$' -f (Get-Date))

    [object[]]$fixtures = Invoke-Command -ScriptBlock { $RunResult.Errors ; $RunResult.Failures ; $RunResult.Passed } |
                                Group-Object -Property 'FixtureName'

    $fixtureCount = 0
    if( $fixtures )
    {
        $fixtureCount = $fixtures.Count
    }
    Assert-Equal (2 + $fixtureCount) $docRoot.ChildNodes.Count

    $total = 0
    $errors = 0
    $failures = 0
    foreach( $fixture in $fixtures )
    {
        $fixtureName = $fixture.Name

        $nodes = $docRoot.SelectNodes( ('test-suite[@name = ''{0}'']' -f $fixtureName) )
        Assert-Equal 1 $nodes.Count

        $testSuite = $nodes[0]
        Assert-Equal 'BladeFixture' $testSuite.type
        Assert-Equal $fixtureName $testSuite.name
        Assert-Equal 'true' $testSuite.'executed' 
        Assert-Equal '0' $testSuite.'asserts'

        $duration = [Timespan]::Zero
        $result = 'Success'
        $success = $true
        foreach( $testResult in $fixture.Group )
        {
            $nodes = $testSuite.SelectNodes( ('results/test-case[@name = ''{0}'']' -f $testResult.Name) )
            Assert-Equal 1 $nodes.Count
            $testCase = $nodes[0]

            Assert-Equal $testResult.Name $testCase.name
            Assert-Equal 'True' $testCase.executed
            Assert-Equal $testResult.Duration.TotalSeconds.ToString() $testCase.time
            Assert-Equal '0' $testCase.asserts

            $duration += $testResult.Duration
            if( -not $testResult.Passed )
            {
                $result = 'Failure'
                $success = $false
                if( $testResult.Error )
                {
                    ++$errors
                }

                if( $testResult.Failure )
                {
                    ++$failures
                }

                Assert-Equal 'Failure' $testCase.result
                Assert-Equal 'False' $testCase.success
            }
            else
            {
                Assert-Equal 'Success' $testCase.result
                Assert-Equal 'True' $testCase.success
            }

            ++$total
        }

        Assert-Equal $testSuite.'time' $duration.TotalSeconds
        Assert-Equal $result $testSuite.'result'
        Assert-Equal $success.ToString() $testSuite.'success'
    }

    Assert-Equal $total $docRoot.Attributes['total'].Value

    Assert-Equal $errors $docRoot.Attributes['errors'].Value
    Assert-Equal $RunResult.Errors.Count $docRoot.Attributes['errors'].Value

    Assert-Equal $failures $docRoot.Attributes['failures'].Value
    Assert-Equal $RunResult.Failures.Count $docRoot.Attributes['failures'].Value

}