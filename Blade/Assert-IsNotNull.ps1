
function Assert-IsNotNull
{
    <#
    .SYNOPSIS
    Asserts that an object isn't `$null`.

    .DESCRIPTION

    .EXAMPLE
    Assert-IsNotNull $null

    Demonstrates how to fail a test by asserting that `$null` isn't `$null`.

    .EXAMPLE
    Assert-IsNotNull $object 'The foo didn''t bar!'

    Demonstrates how to give a descriptive error about why the assertion might be failing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The object to check.
        $InputObject,
        
        [Parameter(Position=1)]
        [string]
        # A reason why the assertion fails. 
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $InputObject -eq $null )
    {
        Fail ("Value is null. {0}" -f $message)
    }
}

Set-Alias -Name 'Assert-NotNull' -Value 'Assert-IsNotNull'