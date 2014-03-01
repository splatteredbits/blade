
function Assert-Equal($expected, $actual, $message)
{
    Write-TestVerbose "Is '$expected' -eq '$actual'?"
    if( -not ($expected -eq $actual) )
    {
        if( $expected -is [string] -and $actual -is [string] -and ($expected.Contains("`n") -or $actual.Contains("`n")))
        {
            for( $idx = 0; $idx -lt $expected.Length; ++$idx )
            {
                if( $idx -gt $actual.Length )
                {
                    Fail ("Strings different, beginning at index {0}:`n{1}`n({2})`n{3}" -f $idx,$expected.Substring(0,$idx),$actual,$message)
                }
                
                if( $expected[$idx] -ne $actual[$idx] )
                {
                    Fail ("Strings different beginning at index {0}: {0}`n{1}`n{2}`n{3}" -f $idx,$expected.Substring(0,$idx),$actual.Substring(0,$idx),$message)
                }
            }
            
        }
        Fail "Expected '$expected', but was '$actual': $message"
    }
}
