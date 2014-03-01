
function Assert-NodeExists($xml, $xpath, $defaultNamespacePrefix, $message)
{
    if( -not (Test-NodeExists $xml $xpath $defaultNamespacePrefix) )
    {
        Fail "Couldn't find node with xpath '$xpath': $message"
    }
}
