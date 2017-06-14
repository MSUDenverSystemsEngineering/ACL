$vmwfs14 = New-PSSession -ComputerName VMWFS14
$applicationName = "Staging - ${Env:APPVEYOR_PROJECT_NAME}"
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\appveyor.yml"
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\deploy.ps1"
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\.gitignore" -Force
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\.gitattributes" -Force
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\.git" -Recurse -Force
Remove-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}\Tests" -Recurse

Copy-Item -Path "${Env:APPLICATION_PATH}\${Env:APPVEYOR_PROJECT_SLUG}" -Destination "H:\Archive\SCCM\Staging\${Env:APPVEYOR_PROJECT_NAME}\${Env:APPVEYOR_BUILD_VERSION}" -ToSession $vmwfs14 -Recurse

Import-Module -Name "$(Split-Path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1"
New-PSDrive -Name "MS1" -PSProvider "AdminUI.PS.Provider\CMSite" -Root "VMWAS117" -Description "MS1"
Set-Location -Path MS1:

New-CMApplication -Name $applicationName -AutoInstall $true
Add-CMDeploymentType -ApplicationName $applicationName -DeploymentTypeName "$applicationName ${Env:APPVEYOR_BUILD_VERSION} PowerShell App Deployment Toolkit" -InstallationProgram "Deploy-Application.exe" -AdministratorComment "AppVeyor test" -AllowClientsToShareContentOnSameSubnet $true -ContentLocation "\\vmwfs14\H$\Archive\SCCM\Staging\${Env:APPVEYOR_PROJECT_NAME}\${Env:APPVEYOR_BUILD_VERSION}" -InstallationBehaviorType "InstallForSystem" -InstallationProgramVisibility "Normal" -LogonRequirementType "WhetherOrNotUserLoggedOn" -MaximumAllowedRunTimeMinutes 720 -PersistContentInClientCache $false -RunInstallationProgramAs32BitProcessOn64BitClient $false -UninstallProgram "Deploy-Application.exe -DeploymentType `"Uninstall`""
