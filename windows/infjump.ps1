function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Install-FromChocolatey {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $PackageName
    )

    choco install $PackageName --yes
}

function Install-PowerShellModule {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $ModuleName,

        [ScriptBlock]
        [Parameter(Mandatory = $true)]
        $PostInstall = { }
    )

    if (!(Get-Command -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $ModuleName"
        Install-Module -Name $ModuleName -Scope CurrentUser -Confirm $true
        Import-Module $ModuleName -Confirm

        Invoke-Command -ScriptBlock $PostInstall
    }
    else {
        Write-Host "$ModuleName was already installed, skipping"
    }
}

Install-Chocolatey

Install-FromChocolatey 'choco-upgrade-all-at-startup'
Install-FromChocolatey 'git'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/RES-Infrastructure/JumpServerCode/main/common/.gitconfig' -OutFile (Join-Path $env:USERPROFILE '.gitconfig')

Install-FromChocolatey 'vscode'
Install-FromChocolatey 'microsoft-windows-terminal'
Install-FromChocolatey 'microsoft-edge-insider-dev'
Install-FromChocolatey '7zip'
Install-FromChocolatey 'putty'
Install-FromChocolatey 'vmrc'
Install-FromChocolatey 'vmware-powercli-psmodule'
Install-FromChocolatey 'rvtools'
Install-FromChocolatey 'sql-server-management-studio'
Install-FromChocolatey 'notepadplusplus'
Install-FromChocolatey 'googlechrome'

Write-Host 'Installing Posh-Git' -ForegroundColor Green
Install-Module 'Posh-Git' -Scope AllUsers -Force

Write-Host 'Installing PSWindowsUpdate' -ForegroundColor Green
Install-Module 'PSWindowsUpdate' -Scope AllUsers -Force

Write-Host 'Installing Administrative tools for AD' -ForegroundColor Green
Add-WindowsFeature rsat-ad-tools -Verbose

Write-Host 'Installing Administrative tools for DHCP' -ForegroundColor Green
Add-WindowsFeature RSAT-DHCP -Verbose

Write-Host 'Installing Administrative tools for DNS' -ForegroundColor Green
Add-WindowsFeature RSAT-DNS-Server -Verbose

Write-Host 'Installing Administrative tools for Group Policy' -ForegroundColor Green
Add-WindowsFeature GPMC -Verbose

Write-Host 'Updating PowerShell help files' -ForegroundColor Green
Update-Help -Force

Write-Host 'Getting and installing windows updates' -ForegroundColor Green
Get-Package -Name PSWindowsUpdate
Import-Module PSWindowsUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

Write-Host "Enable Auto Upload and Auto Download in Code Sync Settings" -ForegroundColor Green
Write-Host 'Rebooting in 60 seconds to finalise installations...' -ForegroundColor Magenta


Start-Sleep -seconds 60
Restart-Computer -Force
