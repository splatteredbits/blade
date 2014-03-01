
function Assert-ContainsNotLike($haystack, $needle, [Parameter(Mandatory=$true)]$message)
{
    foreach( $line in $haystack )
    {
        if( $line -like "*$needle*" )
        {
            Fail "Found '$needle': $message"
        }
    }
}
