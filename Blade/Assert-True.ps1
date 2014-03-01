
function Assert-True($condition, $message)
{
    if( -not $condition )
    {
        Fail  "Expected true but was false: $message"
    }
}
