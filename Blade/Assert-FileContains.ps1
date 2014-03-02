
function Assert-FileContains
{
    <#
    .SYNOPSIS
    Asserts that a file contains another string.

    .DESCRIPTION
    Performs a case-sensitive check for the string within the file.  

    .EXAMPLE
    Assert-FileContains 'C:\Windows\System32\drivers\etc\hosts' '127.0.0.1'

    Demonstrates how to assert that a file contains a string.

    .EXAMPLE
    Assert-FileContains 'C:\Windows\System32\drivers\etc\hosts' 'doubclick.net' 'Ad-blocking hosts entry not added.

    Shows how to use the `Message` parameter to describe why the assertion might fail.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # The path to the file.
        $Path,

        [Parameter(Position=1)]
        [string]
        # The string to look for. Case-sensitive.
        $Needle,

        [Parameter(Position=2)]
        # A description about why the assertion might have failed.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    Write-Verbose "Checking if '$Path' contains expected content."
    $actualContents = Get-Content -Path $Path -Raw
    Write-Verbose "Actual:`n$actualContents"
    Write-Verbose "Expected:`n$Needle"
    if( $actualContents.Contains($Needle) )
    {
        Fail ("File '{0}' does not contain '{1}'. {2}" -f $Path,$Needle,$Message)
    }
}
