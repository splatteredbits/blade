
& (Join-Path -Path $PSScriptRoot -ChildPath '..\Blade\Import-Blade.ps1' -Resolve)

function Test-ShouldDetectNoErrors
{
    Write-Error 'Fubar!' -ErrorAction SilentlyContinue
    Assert-That {
        Assert-Error -Count 0
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'Expected ''0'' errors, but found ''1'''
}