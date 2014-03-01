
function Assert-Like($haystack, $needle, $message)
{
    if( $haystack -notlike "*$needle*" )
    {
        Fail "'$haystack' is not like '$needle': $message" 
    }
}
