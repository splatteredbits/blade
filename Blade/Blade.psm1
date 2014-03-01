
$currentTest = $null

$doNotImport = @{ 'Import-Blade' = $true }

Get-Item -Path (Join-Path $PSScriptRoot '*-*.ps1') | 
    Where-Object { -not $doNotImport.ContainsKey( $_.BaseName ) } |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
