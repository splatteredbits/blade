
function Assert-LessThan($expectedValue, $upperBound, $message)
{
    if( -not ($expectedValue -lt $upperBound) )
    {
        Fail "$expectedValue is not less than $upperBound : $message" 
    }
}
