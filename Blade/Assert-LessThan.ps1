
function Assert-LessThan
{
    <#
    .SYNOPSIS
    Asserts that an expected value is less than a given value.

    .DESCRIPTION
    Uses PowerShell's `-lt` operator to perform the check.

    .EXAMPLE
    Assert-LessThan 1 5 

    Demonstrates how check that 1 is less than 5, ie. `1 -lt 5`.

    .EXAMPLE
    Assert-LessThan 5 1 'Uh-oh. Five is less than 1!'

    Demonstrates how to include a custom message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The value to check.
        $ExpectedValue,

        [Parameter(Position=1)]
        [object]
        # The value to check against, i.e. the value `ExpectedValue` should be less than.
        $UpperBound, 

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( -not ($ExpectedValue -lt $UpperBound) )
    {
        Fail "$ExpectedValue is not less than $UpperBound : $Message" 
    }
}
