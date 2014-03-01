
function Assert-ContainsLike($haystack, $needle, $message)
{
    foreach( $line in $haystack )
    {
        if( $line -like "*$needle*" )
        {
            return
        }
    }
    Fail "Unable to find '$needle': $message" 
}
