
function Assert-True
{
    <#
    .SYNOPSIS
    Asserts a condition is true.

    .DESCRIPTION
    Uses PowerShell's rules for determinig truthiness.  All values are true except:

     * `0`
     * `$false`
     * '' (i.e. `[String]::Empty`)
     * `$null`
     * `@()` (i.e. empty arrays)

    All other values are true.

    .EXAMPLE
    Assert-True $false

    Demonstrates how to fail a test.

    .EXAMPLE
    Assert-True (Invoke-SomethingThatShouldReturnSomething)

    Demonstrates how to check that a function returns a true object/value.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The object/value to test for truthiness.
        $Condition, 

        [Parameter(Position=1)]
        [string]
        # A message to show if `Condition` isn't `$true`.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( -not $condition )
    {
        Fail -Message  "Expected true but was false: $message"
    }
}
