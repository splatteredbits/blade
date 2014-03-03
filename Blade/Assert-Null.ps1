
function Assert-Null
{
    <#
    .SYNOPSIS
    Asserts that an object/value is `$null`.

    .DESCRIPTION
    `Value` is literally compared with `$null`.

    .EXAMPLE
    Assert-Null $null

    Demonstrates how to assert a value is equal to `$null`.

    .EXAMPLE
    Assert-Null '' 'Uh-oh.  Empty string is null.'

    Demonstrates how to assert a value is equal to `$null` and show a custom error message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The value to check.
        $Value, 

        [Parameter(Position=1)]
        [string]
        # The message to show when `Value` if not null.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Value -ne $null )
    {
        Fail "Value '$Value' is not null: $Message"
    }
}

Set-Alias -Name 'Assert-IsNull' -Value 'Assert-Null'