#File with examples about TestDrive, Pester's TDD implementation

Describe 'TestDrive Demo1' {
    BeforeAll {
        Add-Content -Path TestDrive:\test.txt -Value 'test'
    }

    AfterAll {
        Write-Host (Get-Content -Path TestDrive:\test.txt)
    }

    It 'TestDrive exists' {
        'TestDrive:\' | Should -Exist
    }

    It 'The file we created exists' {
        'TestDrive:\test.txt' | Should -Exist
    }

    It 'The content of the file should be test' {
        Get-Content -Path 'TestDrive:\test.txt' | Should -Be 'test'
    }
}