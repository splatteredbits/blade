# TOPIC

about\_Blade

# SHORT DESCRIPTION

# LONG DESCRIPTION

Blade is a testing tool for PowerShell inspired by [NUnit](http://nunit.org).  Test fixtures are PowerShell scripts that begin with the `Test` verb.  A test is any function in the test fixture script that begins with the `Test` verb.

To get started, create a test fixture file:

    > New-Item -ItemType File Test-BladeDemo.ps1

Now, open up your new test fixture, and start adding tests.  

    function Test-ShouldRunThisTest
	{
		Assert-True $true
	}

Save your test fixture, then execute it and you should see output similar to this:

    > blade.ps1 Test-BladeDemo.ps1
	
	   Count Failures   Errors  Ignored Duration        
       ----- --------   ------  ------- --------        
           1        0        0        0 00:00:00        

Pretty easy.  If all your tests have common setup/teardown functionality, add it to the special `Start-Test` and `Stop-Test` functions, which will get run once for *each* test:

    $tempDir = $null
	
    function Start-Test
	{
		$tempDir = New-TempDir
	}
	
	function Stop-Test
	{
		Remove-Item -Path $tempDir -Recurse
	}
	
	function Test-ShouldCreateTempDir
	{
		Assert-DirectoryExists $tempDir
	}
	
Finally, if you have setup/teardown that needs to run once before/after *all* tests, add it the special `Start-TestFixture` and `Stop-TestFixture` functions:

    $tempDir = $null
	
	function Start-TestFixture
	{
		# Import the PowerShell module we're testing.
		& (Join-Path -Path $PSScriptRoot -ChildPath '..\CoolestModuleEver\Import-CoolestModuleEver.ps1' -Resolve)
	}
	
    function Start-Test
	{
		$tempDir = New-TempDir
	}
	
	function Stop-Test
	{
		Remove-Item -Path $tempDir -Recurse
	}
	
	function Stop-TestFixture
	{
		Remove-Module 'CoolestModuleEver'
	}
	
	function Test-ShouldCreateTempDir
	{
		Assert-DirectoryExists $tempDir
	}
