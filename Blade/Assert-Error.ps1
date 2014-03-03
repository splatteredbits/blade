
function Assert-Error
{
    <#
    .SYNOPSIS
    Asserts that there are errors, and/or that a specific error's messages matches a regular expression.

    .DESCRIPTION
    With no parameters, checks that there are errors in the `$Error` array.

    If passed an index and a regular expression, checks that there are errors in the `$Error` array, that there is one at index `Index`, and that it's message matches `$Regex`.

    If you want to check the last/most recent error, use the `-Last` switch.  To check the first/oldest error, use the `-First` switch.

    .EXAMPLE
    Assert-Error
    
    Demonstrates how to check that there is at least one error.

    .EXAMPLE
    Assert-Error 0 'not found'

    Demonstrates how to check that the last error (remember, `$Error` is a stack) matches the regular expression `not found`.

    .EXAMPLE
    Assert-Error -1 'not found'

    Demonstrates how to check that the first error (remember, `$Error` is a stack) matches the regular expression `not found`.

    .EXAMPLE
    Assert-Error -Last 'not found'

    Demonstrates how to check that the last error matches the regular exprssion `not found` without worrying about indexes.

    .EXAMPLE
    Assert-Error -First 'not found'

    Demonstrates how to check that the first error matches the regular exprssion `not found` without worrying about indexes.
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='CheckLastError')]
        [Switch]
        # Checks the last/most recent error.
        $Last,

        [Parameter(Mandatory=$true,ParameterSetName='CheckFirstError')]
        [Switch]
        # Checks the first/oldest error.
        $First,

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='CheckSpecificError')]
        [int]
        # The index of the error to check.
        $Index,

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='CheckLastError')]
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='CheckFirstError')]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='CheckSpecificError')]
        [Regex]
        # The regular expression to check.
        $Regex,

        [Parameter(Position=0,ParameterSetName='Default')]
        [Parameter(Position=1,ParameterSetName='CheckLastError')]
        [Parameter(Position=1,ParameterSetName='CheckFirstError')]
        [Parameter(Position=2,ParameterSetName='CheckSpecificError')]
        [string]
        # A message to show if the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'
    
    Assert-GreaterThan $Global:Error.Count 0 'Expected there to be errors, but there aren''t any.'

    if( $PSCmdlet.ParameterSetName -like 'Check*Error' )
    {
        if( $PSCmdlet.ParameterSetName -eq 'CheckFirstError' )
        {
            $Index = -1
        }
        elseif( $PSCmdlet.ParameterSetName -eq 'CheckLastError' )
        {
            $Index = 0
        }

        Assert-True ($Index -lt $Global:Error.Count) ('Expected there to be at least {0} errors, but there are only {1}. {2}' -f ($Index + 1),$Global:Error.Count,$Message)
        Assert-Match -Haystack $Global:Error[$Index].Exception.Message -Regex $Regex -Message $Message
    }
}