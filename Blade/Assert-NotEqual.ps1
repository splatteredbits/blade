
function Assert-NotEqual($expected, $actual, $message)
{
    if( $expected -eq $actual )
    {
        Fail "Expected '$expected' to be different than '$actual': $message"
    }
}
