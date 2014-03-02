
function Assert-FileDoesNotExist
{
    <#
    .SYNOPSIS
    Asserts that a file does not exist.

    .DESCRIPTION
    Uses PowerShell's `Test-Path` cmdlet to check if a file doesn't exist.

    .EXAMPLE
    Assert-FileDoesNotExist 'C:\foobar.txt'

    Demonstrates how to assert that a does not exist.

    .EXAMPLE
    Assert-FileDoesNotExist 'C:\foobar.txt' 'foobar.txt not removed.'

    Demonstrates how to describe why an assertion might fail.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The path to the file to check.
        $Path,

        [Parameter(Position=1)]
        [string]
        # A description of why the assertion might fail.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( Test-Path -Path $Path -PathType Leaf )
    {
        Fail "File $Path exists: $Message"
    }
}
