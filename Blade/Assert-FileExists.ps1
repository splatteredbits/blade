
function Assert-FileExists($file, $message)
{
    Write-TestVerbose "Testing if file '$file' exists."
    if( -not (Test-Path $file -PathType Leaf) )
    {
        Fail "File $file does not exist.  $message"
    }
}
