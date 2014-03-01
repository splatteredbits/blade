
function Assert-DoesNotContain($Haystack, $Needle, $Message)
{
    if( $Haystack -contains $Needle )
    {
        Fail "Found '$Needle': $Message"
    }
}
