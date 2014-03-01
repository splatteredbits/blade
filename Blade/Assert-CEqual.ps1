
function Assert-CEqual
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Expected,
        [Parameter(Mandatory=$true)]
        [string]
        $Actual,
        [Parameter(Mandatory=$true)]
        [string]
        $Message
    )
    if( $Expected -cne $Actual )
    {
        for( $idx = 0; $idx -lt $expected.Length; ++$idx )
        {
            if( $idx -gt $actual.Length )
            {
                Fail ("Strings different, beginning at index {0}:`n{1}`n({2})`n{3}" -f $idx,$expected.Substring(0,$idx),$actual,$message)
            }
            
            if( $expected[$idx] -cne $actual[$idx] )
            {
                $actualSnippet = if( ($idx + 1) -gt $actual.Length ) { $Actual } else { $Actual.Substring(0, $idx) }
                Fail ("Strings different beginning at index {0}: {0}`n{1}`n{2}`n{3}" -f $idx,$expected.Substring(0,$idx + 1),$actualSnippet,$message)
            }
        }

        Fail "Expected '$Expected', but was '$Actual': $Message"
    }
}
