#Requires -RunAsAdministrator

#Import Windows Forms Classes
Add-Type -AssemblyName System.Windows.Forms
$FormObject = [System.Windows.Forms.Form]
$LabelObject = [System.Windows.Forms.Label]
$ButtonObject = [System.Windows.Forms.Button]
$FontObject = [System.Drawing.Font]
$BigLabelFont = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)

#Main Form
$global:LinkjaCryptoForm = New-Object $FormObject
$global:LinkjaCryptoForm.ClientSize = '500,300'
$global:LinkjaCryptoForm.Text = 'Linkja Crypto'
$global:LinkjaCryptoForm.BackColor = "#aae5ff"
$global:LinkjaCryptoForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::ExpandEnvironmentVariables('%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja.ico'))

#Top Label
$Label = New-Object $LabelObject
$Label.Font = $BigLabelFont
$Label.Text = 'Linkja Crypto Library: Dependency Installer and Generator'
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Point(65, 10)

#Bottom Label
$LabelBottom = New-Object $LabelObject
$LabelBottom.Text = 'A Free/Open Source Product of Cook County Health, linkja.github.io'
$LabelBottom.AutoSize = $true
$LabelBottom.Location = New-Object System.Drawing.Point(90, 270)


#Install Dependencies Button
function InstallDependencies { 
    #$process = [Diagnostics.Process]::new()
    #$process.StartInfo.UseShellExecute = $true
    #$process.StartInfo.Verb = "runas"
    #$res = $process::Start("${env:ProgramFiles(x86)}\Linkja\Linkja Crypto Installer\install_dependencies.exe").WaitForExit(60)
    $res = Start-Process -Wait -PassThru "${env:ProgramFiles(x86)}\Linkja\Linkja Crypto Installer\install_dependencies.exe" 
    #if ($res.ExitCode -ne 0) {
    #    $msgBox = New-Object -ComObject Wscript.Shell
    #    $msgBox.Popup("Dependency Installer experienced an error; please try again or contact Linkja support.", 0, "Linkja Crypto", 0+48)
    #}  

    $msgBox = New-Object -ComObject Wscript.Shell
    $msgBox.Popup("Linkja Dependency Installer is finished running. If it ran successfully, please reopen the Linkja Crypto application to build the Linkja Crypto library. If it failed, please try running it again or contact Linkja support.", 0, "Linkja Crypto", 0+64)
    [System.Environment]::Exit(0)
    #$global:LinkjaCryptoForm.Refresh()
}
$global:BtnInstallDependencies = New-Object $ButtonObject
$global:BtnInstallDependencies.Text = 'Install Dependencies'
$global:BtnInstallDependencies.BackColor = "#f6f6f4"
$global:BtnInstallDependencies.AutoSize = $true
$global:BtnInstallDependencies.Location = New-Object System.Drawing.Point(200,50)
$global:BtnInstallDependencies.Add_Click({InstallDependencies})

#Build Linkja Crypto Button
function BuildLinkjaCrypto {
#$msgBox1 = New-Object -ComObject Wscript.Shell
#$msgBox1.Popup("About to build Linkja Crypto library. If it completes successfully, you will see a command prompt window stating `"Built target linkjacrypto`"", 0, "Linkja Crypto", 0+64)
    #try 
        $proc = [Diagnostics.Process]::new()
        $proc.StartInfo.UseShellExecute = $true
        $proc.StartInfo.Verb = "runas"
        $res = $proc::Start( "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat","&& `"%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja_compile.bat`"").WaitForExit(60)
        #$res = Start-Process -PassThru -Wait "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" -ArgumentList "&& `"%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja_compile.bat`""
    #} catch {
    #    $msgBox3 = New-Object -ComObject Wscript.Shell
    #    $msgBox3.Popup("Linkja Crypto library builder experienced a caught error; please try again or contact Linkja support.", 0, "Linkja Crypto", 0+48)
    #}
    RedrawForm ([ref]$global:BtnInstallDependencies) ([ref]$global:BtnBuildLinkjaCrypto) ([ref]$global:BtnCleanupLinkjaCrypto) ([ref]$global:BtnOpenLinkjaFolder)
    $global:LinkjaCryptoForm.Refresh()
}
$global:BtnBuildLinkjaCrypto = New-Object $ButtonObject
$global:BtnBuildLinkjaCrypto.Text = 'Build Linkja Crypto Library'
$global:BtnBuildLinkjaCrypto.BackColor = "#f6f6f4"
$global:BtnBuildLinkjaCrypto.AutoSize = $true
$global:BtnBuildLinkjaCrypto.Location = New-Object System.Drawing.Point(190,100)
$global:BtnBuildLinkjaCrypto.Enabled = $false
$global:BtnBuildLinkjaCrypto.Add_Click({BuildLinkjaCrypto})


#Cleanup Linkja Crypto Button
function CleanupLinkjaCrypto {
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\CMakeCache.txt"
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\src\linkjacrypto.exp"
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\src\linkjacrypto.lib"
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\src\linkjacrypto.dll"
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\src\linkjacrypto.dll.manifest"
    Remove-Item "$Env:Programfiles\Linkja\linkja-crypto-master\src\include\linkja_secret.h"
    RedrawForm ([ref]$global:BtnInstallDependencies) ([ref]$global:BtnBuildLinkjaCrypto) ([ref]$global:BtnCleanupLinkjaCrypto) ([ref]$global:BtnOpenLinkjaFolder)
    $global:LinkjaCryptoForm.Refresh()
}
$global:BtnCleanupLinkjaCrypto = New-Object $ButtonObject
$global:BtnCleanupLinkjaCrypto.Text = 'Delete Generated Crypto Library'
$global:BtnCleanupLinkjaCrypto.BackColor = "#f6f6f4"
$global:BtnCleanupLinkjaCrypto.AutoSize = $true
$global:BtnCleanupLinkjaCrypto.Location = New-Object System.Drawing.Point(175,150)
$global:BtnCleanupLinkjaCrypto.Add_Click({CleanupLinkjaCrypto})


#Open Linkja Folder Button
function OpenLinkjaFolder {
    Invoke-Item "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\"
}
$global:BtnOpenLinkjaFolder = New-Object $ButtonObject
$global:BtnOpenLinkjaFolder.Text = 'Open Containing Folder for Crypto Library (linkjacrypto.dll)'
$global:BtnOpenLinkjaFolder.BackColor = "#f6f6f4"
$global:BtnOpenLinkjaFolder.AutoSize = $true
$global:BtnOpenLinkjaFolder.Location = New-Object System.Drawing.Point(110,200)
$global:BtnOpenLinkjaFolder.Add_Click({OpenLinkjaFolder})


#Function to check which actions are complete and redraw form accordingly
function RedrawForm {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ref]$RefInstallDependencies,
        [Parameter(Mandatory=$true, Position=1)]
        [ref]$RefBuildLinkjaCrypto,
        [Parameter(Mandatory=$true, Position=2)]
        [ref]$RefCleanupLinkjaCrypto,
        [Parameter(Mandatory=$true, Position=3)]
        [ref]$RefOpenLinkjaFolder
        )
    #Dependencies are installed as noted by the presence of dependencies_installed.txt
    if((Test-Path -Path "${env:ProgramFiles(x86)}\Linkja\Linkja Crypto Installer\dependencies_installed.txt" -PathType Leaf) -eq 'True'){
        $RefInstallDependencies.Value.Enabled = $false
        $RefInstallDependencies.Value.Text = 'Dependencies Installed'
        $RefBuildLinkjaCrypto.Value.Enabled = $true
    } else {
        $RefInstallDependencies.Value.Enabled = $true
        $RefInstallDependencies.Value.Text = 'Install Dependencies'
        $RefBuildLinkjaCrypto.Value.Enabled = $false
    }
    #Linkja Crypto DLL found, so could be deleted
    if ((Test-Path -Path "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll" -PathType Leaf) -eq 'True') {
        $RefCleanupLinkjaCrypto.Value.Enabled = $true
    } else {
        $RefCleanupLinkjaCrypto.Value.Enabled = $false
    }
    #Linkja source folder found, so may be opened
    if ((Test-Path -Path "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\") -eq 'True') {
        $RefOpenLinkjaFolder.Value.Enabled = $true
    } else {
        $RefOpenLinkjaFolder.Value.Enabled = $false
    }
}

RedrawForm ([ref]$global:BtnInstallDependencies) ([ref]$global:BtnBuildLinkjaCrypto) ([ref]$global:BtnCleanupLinkjaCrypto) ([ref]$global:BtnOpenLinkjaFolder)

$global:LinkjaCryptoForm.Controls.AddRange(@($Label, $global:BtnInstallDependencies,$global:BtnBuildLinkjaCrypto,$global:BtnCleanupLinkjaCrypto,$global:BtnOpenLinkjaFolder, $LabelBottom))

#Display the form
$global:LinkjaCryptoForm.ShowDialog()

##Cleans up the form
#$global:LinkjaCryptoForm.Dispose()

