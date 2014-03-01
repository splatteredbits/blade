
function Assert-FileDoesNotExist($file, $message)
{
    if( Test-Path $file -PathType Leaf )
    {
        Fail "File $file exists: $message"
    }
}
