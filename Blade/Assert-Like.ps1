
function Assert-Like
{
    <#
    .SYNOPSIS
    Asserts that one string is like another.

    .DESCRIPTION
    Uses PowerShell's `-like` operator, so simple wildcards are accepted.

    .LINK
    about_comparison_operators

    .EXAMPLE
    Assert-Like 'Haystack' '*stack*'

    Demonstrates how to assert one string is like another.  In this example, the assertion passes, becase `'Haystack' -like '*stack*'`.

    .EXAMPLE
    Assert-Like 'Haystack' 'needle' 'Couldn''t find the needle in haystack!'

    Demonstrates how to show a message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The string to look in.
        $Haystack, 

        [Parameter(Position=1)]
        [string]
        # The string to look for.
        $Needle,

        [Parameter(Position=2)]
        [string]
        # The message to use when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $haystack -notlike "*$needle*" )
    {
        Fail "'$haystack' is not like '$needle': $message" 
    }
}
