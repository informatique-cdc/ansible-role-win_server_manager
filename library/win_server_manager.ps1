#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options             = @{
        pop_wac_console_at_sm_launch = @{ type = "bool"; }
        open_server_manager_at_logon = @{ type = "bool"; }
        open_initial_configuration_tasks_at_logon = @{ type = "bool"; }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$pop_wac_console_at_sm_launch = $module.Params.pop_wac_console_at_sm_launch
$open_server_manager_at_logon = $module.Params.open_server_manager_at_logon
$open_initial_configuration_tasks_at_logon = $module.Params.open_initial_configuration_tasks_at_logon
$check_mode = $module.CheckMode
$registryKey = 'HKLM:\SOFTWARE\Microsoft\ServerManager'
$userRegistryKey ='HKCU:\SOFTWARE\Microsoft\ServerManager'
$diff_before = @{ }
$diff_after = @{ }


<#
    .SYNOPSIS
        Returns the value of the provided in the Name parameter, at the registry
        location provided in the Path parameter.
    .PARAMETER Path
        String containing the path in the registry to the property name.
    .PARAMETER PropertyName
        String containing the name of the property for which the value is returned.
#>
function Get-RegistryPropertyValue {
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $getItemPropertyParameters = @{
        Path        = $Path
        Name        = $Name
        ErrorAction = 'Stop'
    }

    <#
        Using a try/catch block instead of 'SilentlyContinue' to be
        able to unit test a failing registry path.
    #>
    try {
        $getItemPropertyResult = (Get-ItemProperty @getItemPropertyParameters).$Name
    }
    catch {
        $getItemPropertyResult = $null
    }

    return $getItemPropertyResult
}

function ConvertTo-Boolean {
    <#
    .SYNOPSIS
    This function Convert common values to Powershell boolean values $true and $false.
    .PARAMETER value
    Specifies the string to convert.
    #>
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]
        $value
    )
    switch ($value) {
        "y" { return $true; }
        "yes" { return $true; }
        "true" { return $true; }
        "t" { return $true; }
        1 { return $true; }
        "n" { return $false; }
        "no" { return $false; }
        "false" { return $false; }
        "f" { return $false; }
        0 { return $false; }
    }
}

<#
    .SYNOPSIS
        Gets the current values of the Windows Admin Center registry entries.
    .OUTPUTS
        Returns a hashtable containing the values.
#>
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()

    return @{
        pop_wac_console_at_sm_launch = -not (Get-RegistryPropertyValue -Path $registryKey -Name 'DoNotPopWACConsoleAtSMLaunch' | ConvertTo-Boolean)
        open_server_manager_at_logon = -not (Get-RegistryPropertyValue -Path $registryKey -Name 'DoNotOpenServerManagerAtLogon' | ConvertTo-Boolean)
        open_initial_configuration_tasks_at_logon = -not (Get-RegistryPropertyValue -Path $registryKey -Name 'DoNotOpenInitialConfigurationTasksAtLogon' | ConvertTo-Boolean)
        checked_unattend_launch_setting = (Get-RegistryPropertyValue -Path $userRegistryKey -Name 'CheckedUnattendLaunchSetting' | ConvertTo-Boolean)
    }
}


function Set-ServerManagerBooleanProperty {
    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled,
        [string]
        $Path = $registryKey
    )
    try {
        $defaultSetItemPropertyParameters = @{
            Path        = $Path
            ErrorAction = 'Stop'
        }
        $value = if ($Enabled) { 1 } else { 0 }
        if (-not $check_mode) {
            Set-ItemProperty @defaultSetItemPropertyParameters -Name $Name -Value $value
        }
    }
    catch {
        $module.FailJson("An error occurs when changing the $Name property: $($_.Exception.Message)", $_)
    }
}

function Set-TargetResource {
    param
    (
        [Parameter()]
        [System.Boolean]
        $pop_wac_console_at_sm_launch,
        [Parameter()]
        [System.Boolean]
        $open_server_manager_at_logon,
        [Parameter()]
        [System.Boolean]
        $open_initial_configuration_tasks_at_logon
    )

    $getTargetResourceResult = Get-TargetResource
    $module.Result.changed = $false

    if ($PSBoundParameters.ContainsKey('pop_wac_console_at_sm_launch')) {
        if ($getTargetResourceResult.pop_wac_console_at_sm_launch -ne $pop_wac_console_at_sm_launch) {
            Set-ServerManagerBooleanProperty -Name 'DoNotPopWACConsoleAtSMLaunch' -Enabled (-not ($pop_wac_console_at_sm_launch))
            $diff_after.pop_wac_console_at_sm_launch = $pop_wac_console_at_sm_launch
            $module.Result.changed = $true
        }
    }

    if ($PSBoundParameters.ContainsKey('open_server_manager_at_logon')) {
        if ($getTargetResourceResult.open_server_manager_at_logon -ne $open_server_manager_at_logon) {
            Set-ServerManagerBooleanProperty -Name 'DoNotOpenServerManagerAtLogon' -Enabled (-not ($open_server_manager_at_logon))
            $diff_after.open_server_manager_at_logon = $open_server_manager_at_logon
            $module.Result.changed = $true
            Set-ServerManagerBooleanProperty -Name 'DoNotOpenServerManagerAtLogon' -Enabled (-not ($open_server_manager_at_logon)) -Path $userRegistryKey
        }

        if ($getTargetResourceResult.open_initial_configuration_tasks_at_logon -ne $open_server_manager_at_logon) {
            Set-ServerManagerBooleanProperty -Name 'DoNotOpenInitialConfigurationTasksAtLogon' -Enabled (-not ($open_server_manager_at_logon))
            $diff_after.open_initial_configuration_tasks_at_logon = $open_server_manager_at_logon
            $module.Result.changed = $true
        }

        if ($getTargetResourceResult.checked_unattend_launch_setting -ne $open_server_manager_at_logon) {
            Set-ServerManagerBooleanProperty -Name 'CheckedUnattendLaunchSetting' -Enabled $open_server_manager_at_logon -Path $userRegistryKey
            $diff_after.checked_unattend_launch_setting = $open_server_manager_at_logon
            $module.Result.changed = $true
        }
    }

    if ($PSBoundParameters.ContainsKey('open_initial_configuration_tasks_at_logon')) {
        if ($getTargetResourceResult.open_initial_configuration_tasks_at_logon -ne $open_initial_configuration_tasks_at_logon) {
            Set-ServerManagerBooleanProperty -Name 'DoNotOpenInitialConfigurationTasksAtLogon' -Enabled (-not ($open_initial_configuration_tasks_at_logon))
            $diff_after.open_initial_configuration_tasks_at_logon = $open_initial_configuration_tasks_at_logon
            $module.Result.changed = $true
        }
    }

    $diff_after.Keys | ForEach-Object {
        $diff_before.$_ = $getTargetResourceResult.$_
    }
}

$setTargetResourceParameters = @{}

if ($null -ne $pop_wac_console_at_sm_launch) {
    $setTargetResourceParameters.pop_wac_console_at_sm_launch = $pop_wac_console_at_sm_launch
}
if ($null -ne $open_server_manager_at_logon ) {
    $setTargetResourceParameters.open_server_manager_at_logon  = $open_server_manager_at_logon
}
if ($null -ne $open_initial_configuration_tasks_at_logon) {
    $setTargetResourceParameters.open_initial_configuration_tasks_at_logon = $open_initial_configuration_tasks_at_logon
}

Set-TargetResource @setTargetResourceParameters

$module.result.config = Get-TargetResource

if ($module.Result.changed) {
    $module.Diff.before = $diff_before
    $module.Diff.after = $diff_after
}

$module.ExitJson()