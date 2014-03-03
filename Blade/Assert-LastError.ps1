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

function Assert-LastError
{
    <#
    .SYNOPSIS
    Asserts if the last error's (e.g. `$Error[0]`) messages matches a given string.

    .DESCRIPTION
    This test uses the `-match` operator to check if `$Error[0]` matches parameter `ExpectedError`.

    .EXAMPLE
    Assert-LastError 'not found'

    Demonstrates how to check that that last error's message matches the regular expression `not found`.

    .EXAMPLE
    Assert-LastError '\d+ files found'
    
    Demonstrates that the `ExpectedError` parameter is a regular expression.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The expected error message for the last error.
        $ExpectedError, 

        [Parameter(Position=1)]
        [string]
        # A custom message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    if( $Error[0] -notmatch $ExpectedError )
    {
        Fail "Last error '$($Error[0].Message)' did not match '$ExpectedError'." 
    }
}

Set-Alias -Name 'Assert-LastPipelineError' -Value 'Assert-LastError'
