
function Assert-GreaterThan($expectedValue, $lowerBound, $message)
{
    if( -not ($expectedValue -gt $lowerBound ) )
    {
        Fail "'$expectedValue' is not greater than '$lowerbound': $message"
    }
}
