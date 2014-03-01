
function Assert-NoError($message)
{
    if( $error.Count -gt 0 )
    {
        Fail "Found $($error.Count) errors, expected none.  $message" 
    }
}

Set-Alias -Name 'Assert-NoErrors' -Value 'Assert-NoError'