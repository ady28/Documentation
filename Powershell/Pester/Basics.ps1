#A basic describe with a test
Describe 'Test suite 1' {
    It 'first test' {
        $true | Should  -Be $true
    }
}

Describe 'Test suite 2' {
    Context 'Boolean' {
        It '$true should be $true' {
            $true | Should -Be $true
        }
    }
    Context 'Arithmetic' {
        It '1+1 should be 2' {
            1+1 | Should -Be 2
        }
        It '3-2 should be 1' {
            3-2 | Should -Be 1
        }
    }
    Context 'String' {

        BeforeAll {
            $StringToTest = 'team'
        }

        It 'test should be test' {
            'test' | Should -Be 'test'
        }
        It 'te+st should be test' {
            'te'+'st' | Should -Be 'test'
        }
        It "An i should not be in <StringToTest>" {
            $StringToTest | Should -Not -BeLike '*i*'
        }
        It "An e should be in <StringToTest>" {
            $StringToTest | Should -BeLike '*e*'
        }
    }
}