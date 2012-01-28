
function Setup
{
    ""  | Out-File (Join-Path $env:TEMP Test-Pest.marker)
}

function Test-DoNothing
{
}