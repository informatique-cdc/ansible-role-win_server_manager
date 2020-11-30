# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

.$(Join-Path -Path $Here -ChildPath 'test_utils.ps1')

# Update Pester if needed
Update-Pester

#Get Function Name
$moduleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Resolve Path to Module path
$ansibleModulePath = "$Here\..\..\library\$moduleName.ps1"

Invoke-TestSetup

Function Invoke-AnsibleModule {
    [CmdletBinding()]
    Param(
        [hashtable]$params
    )

    begin {
        $global:complex_args = @{
            "_ansible_check_mode" = $false
            "_ansible_diff"       = $true
        } + $params
    }
    Process {
        . $ansibleModulePath
        return $module.result
    }
}

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\ServerManager'
$UserRegistryPath = 'HKCU:\SOFTWARE\Microsoft\ServerManager'

try {

    Describe 'win_server_manager' -Tag 'Set' {

        Context 'Configure Windows Admin Center' {

            BeforeAll {

                Mock Get-ItemProperty {
                    return @{ DoNotPopWACConsoleAtSMLaunch = 0  }
                } -ParameterFilter { $Name -eq 'DoNotPopWACConsoleAtSMLaunch' -and $Path -eq $RegistryPath }

                Mock Get-ItemProperty {
                    return @{ DoNotOpenServerManagerAtLogon = 0  }
                } -ParameterFilter { $Name -eq 'DoNotOpenServerManagerAtLogon' -and $Path -eq $RegistryPath }

                Mock Get-ItemProperty {
                    return @{ DoNotOpenInitialConfigurationTasksAtLogon = 0  }
                } -ParameterFilter { $Name -eq 'DoNotOpenInitialConfigurationTasksAtLogon' -and $Path -eq $RegistryPath }

                Mock Get-ItemProperty {
                    return @{ CheckedUnattendLaunchSetting = 1  }
                } -ParameterFilter { $Name -eq 'CheckedUnattendLaunchSetting' -and $Path -eq $UserRegistryPath }


                Mock Set-ItemProperty {
                    Write-Host "Item $Name is set in the registry with $([string]$Value) in $Path"
                } -ParameterFilter { $Path -eq $RegistryPath -or $Path -eq $UserRegistryPath }
            }

            It 'Should return the configuration only' {

                $params = @{ }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $false
                $result.Config.pop_console_at_sm_launch | Should -Be $true
                $result.Config.open_server_manager_at_logon  | Should -Be $true
                $result.Config.open_initial_configuration_tasks_at_logon | Should -Be $true
            }

            It 'Should pop_console_at_sm_launch' {

                $params = @{
                    pop_console_at_sm_launch = $false
                    open_server_manager_at_logon = $false
                    open_initial_configuration_tasks_at_logon = $false
                }

                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.pop_console_at_sm_launch | Should -Be $true
                $result.diff.after.pop_console_at_sm_launch | Should -Be $false
                $result.diff.after.open_server_manager_at_logon | Should -Be $false
                $result.diff.after.open_initial_configuration_tasks_at_logon | Should -Be $false
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}