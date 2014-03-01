
function Assert-NotEmpty($item, $message)
{
    if( -not ($item) -or ($item.Length -eq 0 -or $item.Count -eq 0) )
    {
        Fail  "Found empty variable: $message"
    }
}
