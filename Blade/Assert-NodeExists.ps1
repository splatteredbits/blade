
function Assert-NodeExists
{
    <#
    .SYNOPSIS
    Asserts that a node exist in an XML document.

    .DESCRIPTION
    It's usually pretty easy in PowerShell to check if a node exists in an XML document: simply test if a property exists on that node.  If, however, that XML document has namespaces, you have to do extra setup with the XML document so that you can find the node.  This function does that work for you.

    .LINK
    Assert-NodeDoesNotExist

    .LINK
    Test-NodeExists

    .EXAMPLE
    Assert-NodeExists '<foo><bar><baz /></bar></foo>' '/foo/bar/baz'

    Demonstrates how to assert that an XML document contains a node.

    .EXAMPLE
    Assert-NodeExists '<foo><bar><baz /></bar></foo>' '/foo/bar/baz' -Message 'XML document not processed!'

    Demonstrates how to show a more descriptive error if the assertion fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [xml]
        # The XML document to check.
        $Xml,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The XPath expression for the node to check.
        $XPath,

        [Parameter(Position=2)]
        [string]
        # The short prefix for the document's default namespace, if any.
        $DefaultNamespacePrefix, 

        [Parameter()]
        [string]
        # The message to describe the failure if the assertion fails.
        $Message
    )

    if( -not (Test-NodeExists $xml $xpath $defaultNamespacePrefix) )
    {
        Fail "Couldn't find node with xpath '$xpath': $message"
    }
}
