
function Assert-LastProcessSucceeded
{
    <#
    .SYNOPSIS
    Asserts that the last process succeeded by checking PowerShell's `$LastExitCode` automatic variable.

    .DESCRIPTOIN
    A process succeeds if `$LastExitCode` is zero.

    .EXAMPLE
    Assert-LastProcessSucceeded

    Demonstrates how to assert that the last process succeeded.

    .EXAMPLE
    Assert-LastProcessSucceeded 'cmd.exe'

    Demonstrates how to show a custom message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The message to show if the assertion fails.
        $Message
    )

    if( $LastExitCode -ne 0 )
    {
        Fail "Expected process to succeed, but it failed (exit code: $LastExitCode).  $Message" 
    }
}
