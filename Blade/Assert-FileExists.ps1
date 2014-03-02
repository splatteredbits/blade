
function Assert-FileExists
{
    <#
    .SYNOPSIS
    Asserts that a file exists.

    .DESCRIPTION
    Uses PowerShell's `Test-Path` cmdlet to check if the file exists.

    .EXAMPLE
    Assert-FileExists 'C:\Windows\system32\drivers\etc\hosts'

    Demonstrates how to assert that a file exists.

    .EXAMPLE
    Assert-FileExists 'C:\foobar.txt' 'Foobar.txt wasn''t created.'

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

    Write-Verbose "Testing if file '$Path' exists."
    if( -not (Test-Path $Path -PathType Leaf) )
    {
        Fail "File $Path does not exist. $Message"
    }
}
