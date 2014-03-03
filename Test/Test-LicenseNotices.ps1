# Copyright 2012 - 2014 Aaron Jensen
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

function Start-Test
{
}

function Stop-Test
{
}

function Test-AllFilesShouldHaveLicense
{
    $projectRoot = Join-Path $TestDir .. -Resolve
    $licenseFilePath = Join-Path $projectRoot LICENSE.txt -Resolve
    
    $noticeLines = New-Object Collections.Generic.List[string]
    $foundNotice = $false
    
    Get-Content $licenseFilePath | ForEach-Object {
        if( $_ -eq '   Copyright 2012 - [yyyy] [name of copyright owner]' )
        {
            $_ = $_ -replace '\[yyyy\]',(Get-Date).Year
            $_ = $_ -replace '\[name of copyright owner\]','Aaron Jensen'
            $foundNotice = $true
        }
        
        if( -not $foundNotice )
        {
            return
        }
        
        $trimmedLine = $_
        if( $_.Length -gt 3 )
        {
            $trimmedLine = $_.Substring( 3 )
        }
        $noticeLines.Add( '# ' + $trimmedLine )
    }
    
    $expectedNotice = $noticeLines -join [Environment]::NewLine
    $filesToSkip = @(
        '*Blade\blade.ps1',
        '*Blade\Blade.format.ps1xml',
        '*Test\Fixtures\*',
        '*Publish-Blade.ps1'
    )
    
    $filesMissingLicense = New-Object Collections.Generic.List[string]
    
    Get-ChildItem $projectRoot *.ps*1 -Recurse | 
        Where-Object { -not $_.PsIsContainer -and $_.FullName -notmatch '\\(.hg|Tools\\Silk)\\'  } |
        Where-Object { 
            $fullName = $_.FullName
            return (-not ( $filesToSkip | Where-Object { $fullName -like $_ } ) )
        } | ForEach-Object {
            $projectFile = Get-Content $_.FullName -Raw
            Assert-NotEmpty $projectFile $_.FullName
            if( -not $projectFile.StartsWith( $expectedNotice ) )
            {
                $filesMissingLicense.Add( $_.FullName.Remove( 0, $projectRoot.Length + 1 ) )
            }
        }
    
    Assert-Equal 0 $filesMissingLicense.Count "The following files are missing license notices:`n$($filesMissingLicense -join "`n")"
}
