
function Assert-DoesNotContain
{
    <#
    .SYNOPSIS
    Asserts that a collection doesn't contain an object/item.

    .DESCRIPTION
    Use's PowerShell's `-contains` operator to check that a collection is missing an object/item.

    .EXAMPLE
    Assert-DoesNotContains @( 1, 2, 3 ) 4

    Demonstrates how to assert a collection doesn't contain an item.

    .EXAMPLE
    Assert-DoesNotContain @( 1, 2, 3 ) 3 'Three is the loneliest number.'

    Demonstrates how to show your own message if the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The collection to check.
        $Haystack, 

        [Parameter(Position=1)]
        [object]
        # The object the collection shouldn't have.
        $Needle, 

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Haystack -contains $Needle )
    {
        Fail "Found '$Needle'. $Message"
    }
}
