
function Assert-LastError
{
    <#
    .SYNOPSIS
    Asserts if the last error's (e.g. `$Error[0]`) messages matches a given string.

    .DESCRIPTION
    This test uses the `-match` operator to check if `$Error[0]` matches parameter `ExpectedError`.

    .EXAMPLE
    Assert-LastError 'not found'

    Demonstrates how to check that that last error's message matches the regular expression `not found`.

    .EXAMPLE
    Assert-LastError '\d+ files found'
    
    Demonstrates that the `ExpectedError` parameter is a regular expression.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The expected error message for the last error.
        $ExpectedError, 

        [Parameter(Position=1)]
        [string]
        # A custom message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Error[0] -notmatch $ExpectedError )
    {
        Fail "Last error '$($Error[0].Message)' did not match '$ExpectedError'." 
    }
}

Set-Alias -Name 'Assert-LastPipelineError' -Value 'Assert-LastError'