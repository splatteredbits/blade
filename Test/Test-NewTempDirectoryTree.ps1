# Copyright 2012 - 2015 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$tempDir = $null
$prefixParam = @{ Prefix = 'Blade-Test-NewTempDirectoryTree' }

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