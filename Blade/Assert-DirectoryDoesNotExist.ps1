
function Assert-DirectoryDoesNotExist($directory, $message)
{
    if( Test-Path $directory -PathType Container )
    {
        Fail "Directory '$directory' exists: $message"
    }
}
