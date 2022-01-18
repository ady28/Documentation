BeforeAll {
    . $PSCommandPath.Replace('.Tests','')
}

Describe 'Test-Cluster' {
    BeforeAll {
        $Test = Test-Cluster -Name 'Name'
    }

    It 'Should return $true' {
        $Test | Should -Be $true
    }
}
Describe 'Start-ClusterTest' {
    BeforeAll {

        Mock -CommandName 'Test-Cluster' -MockWith {
            $true
        }
        Mock -CommandName 'Restart-Cluster' #do nothing

        $ClusterName='CL01'
        $Test = Start-ClusterTest -Name $ClusterName
    }

    It "Tests that <ClusterName> is the function parameter for Test-Cluster" {
        $params=@{
            CommandName = 'Test-Cluster'
            Times = 1
            Exactly = $true
            Scope = 'Describe'
            ParameterFilter = {
                $Name -eq $ClusterName
            }
        }
        #Make sure that the command ran once and the Name parameter is the $ClusterName value
        Assert-MockCalled @params
    }

    Context 'Problem detected with cluster'{
        BeforeAll {
    
            Mock -CommandName 'Test-Cluster' -MockWith {
                $false
            }

            $Test = Start-ClusterTest -Name $ClusterName
        }
    
        It "Attempts to restart the cluster" {
            $params=@{
                CommandName = 'Restart-Cluster'
                Times = 1
                Exactly = $true
                Scope = 'Context'
                ParameterFilter = {
                    $Name -eq $ClusterName
                }
            }
            Assert-MockCalled @params
        }
    }

    Context 'No problems are detected with cluster'{
        BeforeAll {
    
            Mock -CommandName 'Test-Cluster' -MockWith {
                $true
            }

            $Test = Start-ClusterTest -Name $ClusterName
        }
    
        It 'Should return $true' {
            $Test | Should -Be $true
        }
    }
}