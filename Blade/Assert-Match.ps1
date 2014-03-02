
function Assert-Match
{
    <#
    .SYNOPSIS
    Asserts that a string matches a regular expression.

    .DESCRIPTION
    Uses PowerShell's `-match` operator, e.g. `$Haystack -match $Regex`.

    .EXAMPLE
    Assert-Match 'Haystack' 'stack'

    Demonstrates how to check that a string matches  regular expression.

    .EXAMPLE
    Assert-Match 'NONumbers!' '\d' 'Ack! No numbers doesn''t have any numbers.'

    Demonstrates how to show a specific message if the assertion fails.
    #>
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        # The string that should match the regular expression
        $Haystack, 
        
        [Parameter(Position=1,Mandatory=$true)]
        [string]
        # The regular expression to use when matching.
        $Regex, 
        
        [Parameter(Position=2)]
        [string]
        # The message to show when the assertion fails.
        $Message
    )
    
    if( $Haystack -notmatch $Regex )
    {
        Fail "'$Haystack' does not match '$Regex': $Message"
    }
}
