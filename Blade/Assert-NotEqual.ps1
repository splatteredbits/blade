
function Assert-NotEqual
{
    <#
    .SYNOPSIS
    Asserts that two objects aren't equal.

    .DESCRIPTION
    Uses PowerShell's `-eq` operator to determine if the two objects are equal or not.

    .LINK
    Assert-Equal

    .LINK
    Assert-CEqual

    .EXAMPLE
    Assert-NotEqual 'Foo' 'Foo'

    Demonstrates how to assert that `'Foo' -eq 'Foo'`, which they are.

    .EXAMPLE
    Assert-NotEqual 'Foo' 'Bar' 'Didn''t get ''Bar'' result.'

    Demonstrates how to show a reason why a test might have failed.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        # The expected value.
        $Expected, 
        
        [Parameter(Position=1)]
        # The actual value.
        $Actual, 
        
        [Parameter(Position=2)]
        # A descriptive error about why the assertion might fail.
        $Message
    )

    if( $Expected -eq $Actual )
    {
        Fail ('{0} is equal to {1}. {2}' -f $Expected,$Actual,$Message)
    }
}
