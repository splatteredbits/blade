
function Assert-Is($object, $expectedType)
{
    if( -not ($object -is $expectedType) )
    {
        Fail "Expected object to be of type '$expectedType' but was $($object.GetType())."
    }
}
