
$tempDir = $null
$prefixParam = @{ Prefix = 'Pest-Test-NewTempDirectoryTree' }

function Setup
{
}

function TearDown
{
    if( $tempDir -and (Test-Path $tempDir) )
    {
        Remove-Item -Path $tempDir -Recurse
    }
}

function Test-ShouldCreateTempDirectory
{
    $tempDir = New-TempDirectoryTree -Tree '' @prefixParam
    Assert-NotNull $tempDir
    Assert-DirectoryExists $tempDir
}

function Test-ShouldCreateFiles
{
    $tempDir = New-TempDirectoryTree -Tree "* File1`n*File2`n" @prefixParam
    Assert-NotNull $tempDir
    Assert-FileExists (Join-Path $tempDir File1)
    Assert-FileExists (Join-Path $tempDir File2)
}

function Test-ShouldCreateDirectories
{
    $tempDir = New-TempDirectoryTree -Tree "+ Directory1`n+Directory2`n" @prefixParam
    Assert-NotNull $tempDir
    Assert-DirectoryExists (Join-Path $tempDir Directory1)
    Assert-DirectoryExists (Join-Path $tempDir Directory2)
}

function Test-ShouldHandleDuplicates
{
    $error.Clear()
    $tempDir = New-TempDirectoryTree -Tree "+ Directory1`n*File1`n+Directory1`n* File1`n" @prefixParam -ErrorAction SilentlyContinue
    Assert-Equal 0 $error.Count
    Assert-NotNull $tempDir
    Assert-DirectoryExists (Join-Path $tempDir Directory1)
    Assert-FileExists (Join-Path $tempDir File1)
}

function Test-ShouldCreateTreeWithDepth
{
    $tempDir = New-TempDirectoryTree -Tree @'
+ ParentDir
  + ChildDir
    * GrandchildFile
  * ChildFile
+ ParentDir2
  + ChildDir
    + GrandchildDir
      * GreatGrandchildFile
  * ChildFile
* RootFile
'@ @prefixParam

    Assert-NotNull $tempDir
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir\ChildDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir2')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir2\ChildDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir2\ChildDir\GrandchildDir')
    
    Assert-FileExists (Join-Path $tempDir 'RootFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildDir\GrandchildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir2\ChildDir\GrandchildDir\GreatGrandchildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir2\ChildFile')
}

function Test-ShouldHandleDuplicateTrees
{
    $tempDir = New-TempDirectoryTree -Tree @'
+ ParentDir
  + ChildDir
    * GrandchildFile
  * ChildFile
+ ParentDir
  + ChildDir
    + GrandchildDir
      * GreatGrandchildFile
  * ChildFile
* RootFile
'@ @prefixParam

    Assert-NotNull $tempDir
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir\ChildDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir\ChildDir')
    Assert-DirectoryExists (Join-Path $tempDir 'ParentDir\ChildDir\GrandchildDir')
    
    Assert-FileExists (Join-Path $tempDir 'RootFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildDir\GrandchildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildDir\GrandchildDir\GreatGrandchildFile')
    Assert-FileExists (Join-Path $tempDir 'ParentDir\ChildFile')
}