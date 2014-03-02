
function Assert-Is
{
    <#
    .SYNOPSIS
    Asserts that an object is a specific type.

    .DESCRIPTION
    Uses PowerShell's `-is` operator to check that `InputObject` is the `ExpectedType` type.

    .EXAMPLE
    Assert-Is 'foobar' ([string])

    Demonstrates how to assert an object is of a specific type.

    .EXAMPLE
    Assert-Is 1 'double' 'Not enough decimals!'

    Demonstrates how to show a message describing why the test might fail.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The object whose type to check.
        $InputObject,

        [Parameter(Position=1)]
        [Type]
        # The expected type of the object.
        $ExpectedType,

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $InputObject -isnot $ExpectedType ) 
    {
        Fail ("Expected object to be of type '{0}' but was '{1}'. {2}" -f $ExpectedType,$InputObject.GetType(),$Message)
    }
}
