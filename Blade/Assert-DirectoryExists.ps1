
function Assert-DirectoryExists
{
    <#
    .SYNOPSIS
    Asserts that a directory exists.

    .DESCRIPTION
    Uses PowerShell's `Test-Path` cmdlet to check if a directory exists.

    .EXAMPLE
    Assert-DirectoryExists 'C:\Windows'

    Demonstrates how to assert that a directory exists.

    .EXAMPLE
    Assert-DirectoryExists 'C:\Foobar' 'Foobar wasn''t created.'

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

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        Fail "Directory $Path does not exist. $Message"
    }
}
