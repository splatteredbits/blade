
function Assert-Equal
{
    <#
    .SYNOPSIS
    Asserts that two objects are equal.

    .DESCRIPTION
    Uses PowerShell's `-eq` operator to test if two objects are equal.  To perform a case-sensitive comparison with the `-ceq` operator, use the `-CaseSensitive` switch.

    .EXAMPLE
    Assert-Equal 'foo' 'FOO'

    Demonstrates that the equality is case-insensitive.

    .EXAMPLE
    Assert-Equal 'foo' 'FOO' -CaseSensitive

    Demonstrates that the equality is case-insensitive.

    .EXAMPLE
    Assert-Equal 'foo' 'bar' 'The bar didn''t foo!'

    Demonstrates how to include your own message when the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The expected value.
        $Expected, 

        [Parameter(Position=1)]
        [object]
        # The actual value.
        $Actual, 

        [Parameter(Position=2)]
        [string]
        # A message to show when the assertion fails.
        $Message,

        [Switch]
        # Performs a case-sensitive equality comparison.
        $CaseSensitive
    )

    Set-StrictMode -Version 'Latest'

    Write-Verbose "Is '$Expected' -eq '$Actual'?"
    $equal = $Expected -eq $Actual
    if( $CaseSensitive )
    {
        $equal = $Expected -ceq $Actual
    }

    if( -not $equal )
    {
        if( $Expected -is [string] -and $Actual -is [string] -and ($Expected.Contains("`n") -or $Actual.Contains("`n")))
        {
            for( $idx = 0; $idx -lt $Expected.Length; ++$idx )
            {
                if( $idx -gt $Actual.Length )
                {
                    Fail ("Strings different beginning at index {0}:`n{1}`n({2})`n{3}" -f $idx,$Expected.Substring(0,$idx),$Actual,$Message)
                }
                
                $charEqual = $Expected[$idx] -eq $Actual[$idx]
                if( $CaseSensitive )
                {
                    $charEqual = $Expected[$idx] -ceq $Actual[$idx]
                }
                if( -not $charEqual )
                {
                    Fail ("Strings different beginning at index {0}: {0}`n{1}`n{2}`n{3}" -f $idx,$Expected.Substring(0,$idx),$Actual.Substring(0,$idx),$Message)
                }
            }
            
        }
        Fail "Expected '$Expected', but was '$Actual'. $Message"
    }
}
