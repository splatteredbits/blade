
function Assert-Empty($item, $message)
{
    if( $item -and ($item.Length -gt 0 -or $item.Count -gt 0) )
    {
        Fail "Expected '$item' to be empty: $message"
    }
}
