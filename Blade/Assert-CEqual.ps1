
function Assert-CEqual
{
    <#
    .SYNOPSIS
    OBSOLETE.  Use `Assert-Equal -CaseSenstive` instead.

    .DESCRIPTION
    OBSOLETE.  Use `Assert-Equal -CaseSenstive` instead.

    .EXAMPLE
    Assert-Equal 'foo' 'FOO' -CaseSensitive

    Demonstrates how to use `Assert-Equal` instead of `Assert-CEqual`.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The expected string.
        $Expected,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The actual string.
        $Actual,

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message
    )

    Write-Warning ('Assert-CEqual is obsolete.  Use Assert-Equal with the -CaseSensitive switch instead.')
    Assert-Equal -Expected $Expected -Actual $Actual -Message $Message -CaseSensitive
}
