
function Assert-ContainsNotLike
{
    <#
    .SYNOPSIS
    Asserts that a collections doesn't contain an item, using wildcards when comparing.

    .DESCRIPTION
    Compares each item in a collection for a value using PowerShell's `-like` operator.

    .EXAMPLE
    Assert-ContainsNotLike @( 'foo', 'bar', 'baz' ) '*z'

    Demonstrates how to check if a collection doesn't contain an item, using wildcards when comparing.

    .EXAMPLE
    Assert-ContainsNotLike @( 'foo', 'bar' ) '*az' 'No az!'

    Demonstrates how to supply your own message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The collection to check.
        $Haystack, 

        [Parameter(Position=1)]
        [object]
        # The object to check that the collection doesn't contain. Wildcards supported.
        $Needle, 

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    foreach( $item in $Haystack )
    {
        if( $item -like "*$Needle*" )
        {
            Fail "Found '$Needle': $Message"
        }
    }
}
