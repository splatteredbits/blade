
function Assert-Contains
{
    <#
    .SYNOPSIS
    Asserts that a collection contains an object/item.

    .DESCRIPTION
    Use's PowerShell's `-contains` operator to check if a collection contains an object/item.

    .EXAMPLE
    Assert-Contains @( 1, 2, 3 ) 3

    Demonstrates how to assert a collection contains an item.

    .EXAMPLE
    Assert-Contain @( 1, 2 ) 3 'Three is the loneliest number.'

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
        # The object to check the collection for.
        $Needle, 

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Haystack -notcontains $Needle )
    {
        Fail "Unable to find '$Needle'. $Message"
    }
}
