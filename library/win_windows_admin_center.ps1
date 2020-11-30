#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options             = @{
        pop_console_at_sm_launch = @{ type = "bool"; }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$pop_console_at_sm_launch = $module.Params.pop_console_at_sm_launch
$check_mode = $module.CheckMode
$registryKey = 'HKLM:\SOFTWARE\Microsoft\ServerManager'
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
        pop_console_at_sm_launch = -not (Get-RegistryPropertyValue -Path $registryKey -Name 'DoNotPopWACConsoleAtSMLaunch' | ConvertTo-Boolean)
    }
}

function Set-DoNotPopWACConsoleAtSMLaunch {
    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled
    )
    try {
        $defaultSetItemPropertyParameters = @{
            Path        = $registryKey
            ErrorAction = 'Stop'
        }
        $value = if ($Enabled) { 1 } else { 0 }
        Set-ItemProperty @defaultSetItemPropertyParameters -Name 'DoNotPopWACConsoleAtSMLaunch' -Value $value
    }
    catch {
        $module.FailJson("An error occurs when changing the DoNotPopWACConsoleAtSMLaunch property: $($_.Exception.Message)", $_)
    }
}

function Set-TargetResource {
    param
    (
        [Parameter()]
        [System.Boolean]
        $pop_console_at_sm_launch
    )

    $getTargetResourceResult = Get-TargetResource

    if ($PSBoundParameters.ContainsKey('pop_console_at_sm_launch')) {
        if ($getTargetResourceResult.pop_console_at_sm_launch -ne $pop_console_at_sm_launch) {
            if (-not $check_mode) {
                Set-DoNotPopWACConsoleAtSMLaunch -Enabled (-not ($pop_console_at_sm_launch)) # -WhatIf:$check_mode
            }
            $diff_before.pop_console_at_sm_launch = $getTargetResourceResult.pop_console_at_sm_launch
            $diff_after.pop_console_at_sm_launch = $pop_console_at_sm_launch
            $module.Result.changed = $true
        }
        else {
            $module.Result.changed = $false
        }
    }
}

$setTargetResourceParameters = @{}

if ($null -ne $pop_console_at_sm_launch) {
    $setTargetResourceParameters.pop_console_at_sm_launch = $pop_console_at_sm_launch
}
Set-TargetResource @setTargetResourceParameters

$module.result.Config = Get-TargetResource

if ($module.Result.changed) {
    $module.Diff.before = $diff_before
    $module.Diff.after = $diff_after
}

$module.ExitJson()