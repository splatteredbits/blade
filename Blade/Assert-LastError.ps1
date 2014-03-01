
function Assert-LastError($expectedError, $message)
{
    if( $error[0] -notmatch $expectedError )
    {
        Fail "Last error '$($error[0].Message)' did not match '$expectedError'." 
    }
}

Set-Alias -Name 'Assert-LastPipelineError' -Value 'Assert-LastError'