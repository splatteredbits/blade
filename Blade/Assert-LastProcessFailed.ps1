
function Assert-LastProcessFailed
{
    <#
    .SYNOPSIS
    Asserts that the last process failed by checking PowerShell's `$LastExitCode` automatic variable.

    .DESCRIPTOIN
    A process fails if `$LastExitCode` is non-zero.

    .EXAMPLE
    Assert-LastProcessFailed

    Demonstrates how to assert that the last process failed.

    .EXAMPLE
    Assert-LastProcessFailed 'cmd.exe'

    Demonstrates how to show a custom message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The message to show if the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $LastExitCode -eq 0 )
    {
        Fail "Expected process to fail, but it succeeded (exit code: $LastExitCode).  $Message" 
    }
}
