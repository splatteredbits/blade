
function Assert-IsNotNull($value, $message)
{
    if( $value -eq $null )
    {
        Fail "Value is null: $message"
    }
}
