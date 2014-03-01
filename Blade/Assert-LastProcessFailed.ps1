
function Assert-LastProcessFailed($message)
{
    if( $LastExitCode -eq 0 )
    {
        Fail "Expected process to fail, but it succeeded (exit code: $lastExitCode).  $message" 
    }
}
