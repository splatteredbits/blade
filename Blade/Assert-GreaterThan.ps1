
function Assert-GreaterThan
{
    <#
    .SYNOPSIS
    Asserts that a value is greater than another object.

    .DESCRIPTION
    Uses PowerShell's `-gt` operator to determine if `$InputObject -gt $LowerBound`.

    .EXAMPLE
    Assert-GreaterThan 5 1 

    Demonstrates how to check if 5 is greater than 1, which it is, so this assertion passes.

    .EXAMPLE
    Assert-GreaterThan $Error.Count 5 'Not enough errors were thrown.'

    Demonstrates how to use the message parameter to give an explanation of why the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The value to test.
        $InputObject, 

        [Parameter(Position=1)]
        [object]
        # The lower bound for `InputObject`.
        $LowerBound, 

        [Parameter(Position=2)]
        [string]
        # A description of why the assertion might fail.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( -not ($InputObject -gt $LowerBound ) )
    {
        Fail "'$InputObject' is not greater than '$LowerBound': $message"
    }
}
