# 支持参数 启用、禁用

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("enable", "disable")]
    [string]$action
)

# 检查是否以管理员身份运行
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "请以管理员身份运行此脚本。" -ForegroundColor Red
    exit
}

# 检查是否在 Windows 10 或更高版本上运行

$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "此脚本仅适用于 Windows 10 或更高版本。" -ForegroundColor Red
    exit
}

# 检查 Hyper-V 是否已安装
$hyperVFeature = Get-WindowsFeature -Name Hyper-V -ErrorAction SilentlyContinue

# 如果 Hyper-V 未安装，则安装 Hyper-V

if ($action -eq "enable") {
    $virtualizationEnabled = (Get-WmiObject -Class Win32_Processor).VirtualizationFirmwareEnabled
    if (-not $virtualizationEnabled) {
        Write-Host "请在 BIOS 中启用虚拟化。" -ForegroundColor Red
        exit
    }


    if ($hyperVFeature -eq $null) {
        # enable hypervisorlaunchtype  
        # 检查是否启用虚拟化

        

        
        Write-Host "正在安装 Hyper-V..." -ForegroundColor Green
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
        


    }
    else {
        Write-Host "Hyper-V 已安装。" -ForegroundColor Green
    }
}
elseif ($action -eq "disable") {
    if ($hyperVFeature -ne $null) {
        Write-Host "正在卸载 Hyper-V..." -ForegroundColor Green
        Uninstall-WindowsFeature -Name Hyper-V -Restart
    }
    else {
        Write-Host "Hyper-V 未安装。" -ForegroundColor Green
    }
}
else {
    Write-Host "无效的操作。请使用 'enable' 或 'disable'。" -ForegroundColor Red
}
