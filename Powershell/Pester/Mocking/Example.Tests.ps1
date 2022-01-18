Describe 'Test-Cluster' {
    BeforeAll {
        #Dot source the function file
        . $PSCommandPath.Replace('.Tests','')

        Mock -CommandName 'Write-Output' -MockWith {
            'Describe1'
        }

        $ClusterName='CL01'
        $Test = Test-Cluster -Name $ClusterName
    }

    It "Should return 'The cluster <ClusterName> is OK.'" {
        $Test | Should -Be "Describe1"
    }

    Context 'Mocking tests1'{
        BeforeAll {
    
            Mock -CommandName 'Write-Output' -MockWith {
                'Context1'
            }

            $Test = Test-Cluster -Name $ClusterName
        }
    
        It "Should return 'The cluster <ClusterName> is OK.'" {
            $Test | Should -Be "Context1"
        }
    }

    Context 'Mocking tests2'{
        BeforeAll {
    
            Mock -CommandName 'Write-Output' -MockWith {
                'Context2'
            }

            $Test = Test-Cluster -Name $ClusterName
        }
    
        It "Should return 'The cluster <ClusterName> is OK.'" {
            $Test | Should -Be "Context2"
        }
    }

    It "Should return 'The cluster <ClusterName> is OK.'" {
        $Test | Should -Be "Describe1"
    }
}