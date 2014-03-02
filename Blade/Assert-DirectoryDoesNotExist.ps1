
function Assert-DirectoryDoesNotExist
{
    <#
    .SYNOPSIS
    Asserts that a directory doesn't exist.

    .DESCRIPTION
    Uses PowerShell's `Test-Path` cmdlet to check if a directory doesn't exist.

    .EXAMPLE
    Assert-DirectoryExists 'C:\Windows'

    Demonstrates how to assert that a directory doesn't exist.

    .EXAMPLE
    Assert-DirectoryExists 'C:\Foobar' 'Foobar wasn''t removed.'

    Demonstrates how to describe why an assertion might fail.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The path to the directory to check.
        $Path,

        [Parameter(Position=1)]
        [string]
        # A description of why the assertion might fail.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( Test-Path -Path $Path -PathType Container )
    {
        Fail "Directory '$Path' exists. $Message"
    }
}
