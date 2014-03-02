
function Assert-False
{
    <#
    .SYNOPSIS
    Asserts an object is false.

    .DESCRIPTION
    Uses PowerShell's rules for determinig truthiness.  The following objects evaluate to `$false`:

     * `0`
     * `$false`
     * '' (i.e. `[String]::Empty`)
     * `$null`
     * `@()` (i.e. empty arrays)

    All other values are true.

    .EXAMPLE
    Assert-False $true

    Demonstrates how to fail a test.

    .EXAMPLE
    Assert-False (Invoke-SomethingThatShouldFail)

    Demonstrates how to check that a function returns a true object/value.

    .EXAMPLE
    Assert-False $true 'The fladoozle didn't dooflaple.'

    Demonstrates how to use the `Message` parameter to describe why the assertion might have failed.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The value to check.
        $InputObject,
        
        [Parameter(Position=1)]
        [string]
        # A description about why the assertion might fail. 
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $InputObject )
    {
        Fail "Expected false, but was true. $Message"
    }
}
