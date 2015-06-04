
& (Join-Path -Path $PSScriptRoot -ChildPath '..\Blade\Import-Blade.ps1' -Resolve)

function Test-ThrowsShouldFailWhenExceptionNotThrown
{
    $caughtException = $false
    try
    {
        Assert-That { } -Throws ([ApplicationException])
    }
    catch [Blade.AssertionException] 
    {
        $caughtException = $true
        Assert-Match $_.Exception.Message 'did not throw'
    }
}

function Test-ThrowsShouldPasswhenExceptionThrown
{
    Assert-That {
        Assert-That { throw 'Fubar!' } -Throws ([Management.Automation.RuntimeException])
    } -DoesNotThrowException
}

function Test-ThrowsShouldMatchMessage
{
    Assert-That {
        Assert-That { throw 'fubar' } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'fubar'
    } -DoesNotThrowException
}

function Test-ThrowsShouldFailWhenMessageDoesNotMatch
{
    Assert-That {
        Assert-That { throw 'fubar' } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'buzz'
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'Exception message .* doesn''t match'
}

function Test-ThrowsShouldFailIfNotGivenScriptBlock
{
    Assert-That {
        Assert-That 1 -Throws ([ApplicationException])
    } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'must be a ScriptBlock'
}

function Test-DoesNotThrowExceptionShouldFailWhenExceptionThrown
{
    Assert-That {
        Assert-That { throw 'fubar!' } -DoesNotThrowException
    } -Throws ([Blade.AssertionException]) -AndMessageMatches 'threw an exception'
}

function Test-DoesNotThrowExceptionShouldPassWhenNoExceptionThrown
{
    Assert-That {
        Assert-That { } -DoesNotThrowException
    } -DoesNotThrowException
}

function Test-DoesNotThrowExceptionShouldFailIfNotGivenScriptBlock
{
    Assert-That {
        Assert-That 1 -DoesNotThrowException
    } -Throws ([Management.Automation.RuntimeException]) -AndMessageMatches 'must be a ScriptBlock'
}

