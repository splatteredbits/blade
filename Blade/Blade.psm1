
$currentTest = $null

$doNotImport = @{ 'Import-Blade' = $true }

Get-Item -Path (Join-Path $PSScriptRoot '*-*.ps1') | 
    Where-Object { -not $doNotImport.ContainsKey( $_.BaseName ) } |
    ForEach-Object { . $_.FullName }

$privateFunctions = @{ 
                        'Remove-ItemWithRetry' = $true; 
                        'Set-CurrentTest' = $true; 
                        'Set-TestVerbosity' = $true; 
                    }

$publicFunctions = Get-ChildItem -Path 'function:\' |
                        Where-Object { $_.ModuleName -eq 'Blade' } |
                        Where-Object { -not $privateFunctions.ContainsKey( $_.Name ) } |
                        Select-Object -ExpandProperty 'Name'

Export-ModuleMember -Function $publicFunctions -Alias *
