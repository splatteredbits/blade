function Assert-Contains($haystack, $needle, $message)
{
    if( $haystack -notcontains $needle )
    {
        Fail "Unable to find '$needle': $message"
    }
}
