
function Setup
{
}

function TearDown
{
}

function Test-ShouldFail
{
    Assert-True $false "I should fail!"
}
function Test-ShouldFailToo
{
    Assert-True $false "I should fail!"
}
function Test-ShouldFailAlso
{
    Assert-True $false "I should fail!"
}