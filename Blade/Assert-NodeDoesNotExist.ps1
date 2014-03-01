
function Assert-NodeDoesNotExist($xml, $xpath, $defaultNamespacePrefix, $message)
{
    if( Test-NodeExists $xml $xpath $defaultNamespacePrefix )
    {
        Fail "Found node with xpath '$xpath': $message"
    }
}
