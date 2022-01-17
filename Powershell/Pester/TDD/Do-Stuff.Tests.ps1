#Write first only the test for Get-Stuff and run a pester code coverage using the script file
#Then write tests for the other to functions and run a code coverage again
#Run the invoke-pester code coverage with -Show All parameter
Describe 'Test-Foo' {
    BeforeAll {
        #Dot source the function file
        . $PSCommandPath.Replace('.Tests','')

        $GetOut = Get-Stuff
        $TestOut = Test-Stuff
        $SetOut = Set-Stuff
    }

    It 'Should return ''Got stuff''' {
        $GetOut | Should -Be 'Got stuff'
    }
    It 'Should return ''Tested stuff''' {
        $TestOut | Should -Be 'Tested stuff'
    }
    It 'Should return ''Set stuff''' {
        $SetOut | Should -Be 'Set stuff'
    }
}