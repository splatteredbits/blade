
function Assert-NotEmpty
{
    <#
    .SYNOPSIS
    Checks that an object isn't empty. 

    .DESCRIPTION
    This checks that an object's `Length` or `Count` property is greater than 0.  That means this function should be used with strings or collections, or similar objects.

    .EXAMPLE
    Assert-NotEmpty 'That was close!' 

    Demonstrates how to check if a string is empty, which in this case it isn't.

    .EXAMPLE
    Assert-NotEmpty @()

    Demonstrates an easy way to fail a test: assert that an empty array is not empty.

    .EXAMPLE
    Assert-NotEmpty @{ Foo = 'Bar' } 'Settigs not loaded.'

    Demonstrates how to add a message to the failure message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [object]
        # The objec to check.
        $InputObject, 

        [Parameter(Position=1)]
        [string]
        # A descriptive message to show if the object isn't empty.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $InputObject -eq $null )
    {
        Fail "Object is null but expected it to be not empty. {0}" -f $Message
        return
    }

    $hasLength = Get-Member -InputObject $InputObject -Name 'Length'
    $hasCount = Get-Member -InputObject $InputObject -Name 'Count'

    if( -not $hasLength -and -not $hasCount )
    {
        Fail ("Object '{0}' has no Length/Count property, so can't determine if it's empty or not. {1}" -f $InputObject,$Message)
    }

    if( ($hasLength -and $InputObject.Length -lt 1) -or ($hasCount -and $InputObject.Count -lt 1) )
    {
        Fail  ("Object '{0}' not empty. {1}" -f $InputObject,$Message)
    }
}
