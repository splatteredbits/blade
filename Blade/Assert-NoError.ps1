
function Assert-NoError
{
    <#
    .SYNOPSIS
    Tests that the `$Error` stack is empty.

    .DESCRIPTION
    I guess you could just do `Assert-Equal 0 $Error.Count`, but `Assert-NoError` is simpler.

    .EXAMPLE
    Assert-NoError

    Demonstrates how to assert that there are no errors in the `$Error` stack.

    .EXAMPLE
    Assert-NoError -Message 'cmd.exe failed to install junction!'

    Demonstrates how to show a descriptive message when there are errors in the `$Error` stack.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Error.Count -gt 0 )
    {
        Fail "Found $($Error.Count) errors, expected none.  $Message" 
    }
}

Set-Alias -Name 'Assert-NoErrors' -Value 'Assert-NoError'