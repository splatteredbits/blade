
function New-AssertionException($message)
{
    $scopeNum = 0
    $stackTrace = @()
    
    foreach( $item in (Get-PSCallStack) )
    {
        $invocationInfo = $item.InvocationInfo
        $stackTrace +=  "$($item.ScriptName):$($item.ScriptLineNumber) $($invocationInfo.MyCommand)"
    }

    $ex = New-Object 'Blade.AssertionException' $message,$stackTrace
    throw $ex
}

Set-Alias -Name 'Fail' -Value 'New-AssertionException'