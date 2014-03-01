
function New-TempDirectory
{
    <#
    .SYNOPSIS
    Creates a new temporary directory.

    .DESCRIPTION
    The temporary directory is created in the current user's `TEMP` directory (e.g. `$env:TEMP`).  We use `[IO.Path]::GetRandomFilename` for the directory's name.  The directory is returned as a `System.IO.DirectoryInfo` object.

    If/when temporary directories fill up, it can be hard to identify the process(es) responsible. To help identify which tests are creating (and not removing) temporary directories, supply a unique, static name as the value to the `Prefix` parameter.  We recommend the name of the test fixture creating the temp directory.

    .OUTPUTS
    System.IO.DirectoryInfo.

    .EXAMPLE
    $tempDir = New-TempDirectory

    Demonstrates how to create a temporary directory.

    .EXAMPLE
    $tempDir = New-TempDirectory 'Test-NewTempDirectory+'

    Demonstrates how to use a custom, identifiable prefix for your temporary directory's name.  This is helpful for identfying tests that forget to clean up after themselves.
    #>
    param(
        [Parameter(Position=0)]
        [string]
        # An optional prefix for the temporary directory name.  Helps in identifying tests and things that don't properly clean up after themselves.
        $Prefix
    )
    
    Set-StrictMode -Version 'Latest'

    $newTmpDirName = [System.IO.Path]::GetRandomFileName()
    if( $Prefix )
    {
        $Prefix = Split-Path -Leaf -Path $Prefix
        $newTmpDirName = '{0}-{1}' -f $Prefix,$newTmpDirName
    }
    
    New-Item (Join-Path -Path $env:TEMP -ChildPath $newTmpDirName) -Type Directory
}


Set-Alias -Name 'New-TempDir' -Value 'New-TempDirectory'
