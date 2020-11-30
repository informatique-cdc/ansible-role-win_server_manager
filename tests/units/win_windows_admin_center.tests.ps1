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

try {

    Describe 'win_windows_admin_center' -Tag 'Set' {

        Context 'Configure Windows Admin Center' {

            BeforeAll {

                Mock Get-ItemProperty {
                    return @{ DoNotPopWACConsoleAtSMLaunch = 0  }
                } -ParameterFilter { $Name -eq 'DoNotPopWACConsoleAtSMLaunch' -and $Path -eq $RegistryPath }

                Mock Set-ItemProperty {
                    Write-Host "Item $Name is set in the registry with $([string]$Value)"
                } -ParameterFilter { $Path -eq $RegistryPath }
            }

            It 'Should return the configuration only' {

                $params = @{ }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $false
            }

            It 'Should pop_console_at_sm_launch' {

                $params = @{
                    pop_console_at_sm_launch = $false
                }

                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.pop_console_at_sm_launch | Should -Be $true
                $result.diff.after.pop_console_at_sm_launch | Should -Be $false
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}