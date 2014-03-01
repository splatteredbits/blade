
function Assert-Match
{
    param(
        [Parameter(Position=0,Mandatory=$true)]
        # The string that should match the regular expression
        $Haystack, 
        
        [Parameter(Position=1,Mandatory=$true)]
        # The regular expression to use when matching.
        $Regex, 
        
        [Parameter(Position=2)]
        # The message to show when the assertion fails.
        $Message
    )
    
    if( $haystack -notmatch $regex )
    {
        Fail "'$haystack' does not match '$regex': $message"
    }
}
