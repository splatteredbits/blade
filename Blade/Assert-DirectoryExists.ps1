
function Assert-DirectoryExists($directory, $message)
{
    if( -not (Test-Path $directory -PathType Container) )
    {
        Fail "Directory $directory does not exist: $message"
    }
}
