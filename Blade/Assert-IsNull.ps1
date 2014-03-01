
function Assert-IsNull($value, $message)
{
    if( $value -ne $null )
    {
        Fail "Value '$value' is not null: $message"
    }
}
