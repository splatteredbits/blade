
function Assert-LastProcessSucceeded($message)
{
    if( $LastExitCode -ne 0 )
    {
        Fail "Expected process to succeed, but it failed (exit code: $lastExitCode).  $message" 
    }
}
