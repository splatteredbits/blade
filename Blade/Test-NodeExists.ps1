
function Test-NodeExists($xml, $xpath, $defaultNamespacePrefix)
{
    $nsManager = New-Object System.Xml.XmlNamespaceManager( $xml.NameTable )
    if( $xml.DocumentElement.NamespaceURI -ne '' -and $xml.DocumentElement.Prefix -eq '' )
    {
        Write-TestVerbose "XML document has a default namespace, setting prefix to '$defaultNamespacePrefix'."
        $nsManager.AddNamespace($defaultNamespacePrefix, $xml.DocumentElement.NamespaceURI)
    }
    
    $node = $xml.SelectSingleNode( $xpath, $nsManager )
    return $node -ne $null
}
