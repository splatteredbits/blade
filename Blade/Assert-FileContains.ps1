
function Assert-FileContains($file, $expectedContents, $message)
{
    Write-TestVerbose "Checking if '$file' contains expected content."
    $actualContents = (Get-Content $file) -Join "`n"
    Write-TestVerbose "Actual:`n$actualContents"
    Write-TestVerbose "Expected:`n$expectedContents"
    if( -not $actualContents.Contains($expectedContents) )
    {
        Fail "File '$file' does not contain expected contents: $message"
    }
}
