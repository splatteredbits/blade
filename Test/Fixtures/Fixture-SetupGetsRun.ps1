
function Setup
{
    ""  | Out-File (Join-Path $env:TEMP Test-Blade.marker)
}

function Test-DoNothing
{
}