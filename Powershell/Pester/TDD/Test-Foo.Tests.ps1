#Write this test file and then write the function Test-Foo in Test-Foo.ps1
#Check that the test pass and continue writing the function until they do
#Run the invoke-pester with -Output Detail
Describe 'Test-Foo' {
    BeforeAll {
        #Dot source the function file
        . $PSCommandPath.Replace('.Tests','')

        Add-Content -Path 'TestDrive:\FooFile.txt' -Value 'foo'
        Add-Content -Path 'TestDrive:\NoFooFile.txt' -Value 'nofoo'

        $FooOutput = Test-Foo -FilePath 'TestDrive:\FooFile.txt'
        $NoFooOutput = Test-Foo -FilePath 'TestDrive:\NoFooFile.txt'
    }

    It 'When the file contains foo, it should return $true' {
        $FooOutput | Should -Be $true
        $FooOutput | Should -BeOfType 'bool'
        @($FooOutput).Count | Should -Be 1
    }

    It 'When the file does not contain foo, it should return $false' {
        $NoFooOutput | Should -Be $false
        $NoFooOutput | Should -BeOfType 'bool'
        @($NoFooOutput).Count | Should -Be 1
    }
}