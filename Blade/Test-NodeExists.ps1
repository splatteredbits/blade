
function Test-NodeExists
{
    <#
    .SYNOPSIS
    Tests if a node exists in an XML document.

    .DESCRIPTION
    It's usually pretty easy in PowerShell to check if a node exists in an XML document: simply test if a property exists on that node.  If, however, that XML document has namespaces, you have to do extra setup with the XML document so that you can find the node.  This function does that work for you.

    .EXAMPLE
    Test-NodeExists '<foo><bar><baz /></bar></foo>' '/foo/bar/baz'

    Returns `$true` if a node selected by `XPath` is found.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [xml]
        # The XML Document to check
        $Xml,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The XPath to use for the node whose existence to check.
        $XPath,

        [Parameter(Position=2)]
        [string]
        # The prefix of the XML document's default namespace.
        $DefaultNamespacePrefix
    )

    Set-StrictMode -Version 'Latest'

    $nsManager = New-Object 'System.Xml.XmlNamespaceManager' $xml.NameTable
    if( $xml.DocumentElement.NamespaceURI -ne '' -and $xml.DocumentElement.Prefix -eq '' )
    {
        Write-Verbose "XML document has a default namespace, setting prefix to '$defaultNamespacePrefix'."
        $nsManager.AddNamespace($defaultNamespacePrefix, $xml.DocumentElement.NamespaceURI)
    }
    
    $node = $xml.SelectSingleNode( $xpath, $nsManager )
    return ($node -ne $null)
}
