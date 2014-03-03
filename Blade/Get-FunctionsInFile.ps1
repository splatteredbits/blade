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

function Get-FunctionsInFile($testScript)
{
    Write-Verbose "Loading test script '$testScript'."
    $testScriptContent = Get-Content "$testScript"
    if( -not $testScriptContent )
    {
        return @()
    }

    $errors = [Management.Automation.PSParseError[]] @()
    $tokens = [System.Management.Automation.PsParser]::Tokenize( $testScriptContent, [ref] $errors )
    if( $errors -ne $null -and $errors.Count -gt 0 )
    {
        Write-Error "Found $($errors.count) error(s) parsing '$testScript'."
        return
    }
    
    Write-Verbose "Found $($tokens.Count) tokens in '$testScript'."
    
    $functions = New-Object System.Collections.ArrayList
    $atFunction = $false
    for( $idx = 0; $idx -lt $tokens.Count; ++$idx )
    {
        $token = $tokens[$idx]
        if( $token.Type -eq 'Keyword'-and $token.Content -eq 'Function' )
        {
            $atFunction = $true
        }
        
        if( $atFunction -and $token.Type -eq 'CommandArgument' -and $token.Content -ne '' )
        {
            Write-Verbose "Found function '$($token.Content).'"
            [void] $functions.Add( $token.Content )
            $atFunction = $false
        }
    }
    
    return $functions.ToArray()
}

