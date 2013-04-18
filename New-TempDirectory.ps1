
function New-TempDirectory
{
    <#
    .SYNOPSIS
    Creates a new temporary directory.
    #>
    $tmpPath = [System.IO.Path]::GetTempPath()
    $newTmpDirName = [System.IO.Path]::GetRandomFileName()
    New-Item (Join-Path $tmpPath $newTmpDirName) -Type Directory
}


Set-Alias -Name 'New-TempDir' -Value 'New-TempDirectory'
