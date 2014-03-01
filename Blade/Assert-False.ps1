
function Assert-False($expected, $message)
{
    if( $expected )
    {
        Fail "Expected false, but was true: $message"
    }
}
