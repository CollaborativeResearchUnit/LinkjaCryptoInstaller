#Requires -RunAsAdministrator

#Import Windows Forms Classes
Add-Type -AssemblyName System.Windows.Forms
$FormObject = [System.Windows.Forms.Form]
$LabelObject = [System.Windows.Forms.Label]
$ButtonObject = [System.Windows.Forms.Button]
$FontObject = [System.Drawing.Font]
$TextBoxObject = [System.Windows.Forms.TextBox]
$BigLabelFont = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)

#Main Form
$global:LinkjaCryptoForm = New-Object $FormObject
$global:LinkjaCryptoForm.ClientSize = '500,300'
$global:LinkjaCryptoForm.Text = 'Linkja Crypto'
$global:LinkjaCryptoForm.BackColor = "#aae5ff"
$global:LinkjaCryptoForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::ExpandEnvironmentVariables('%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja.ico'))
#Main Form Top Label
$Label = New-Object $LabelObject
$Label.Font = $BigLabelFont
$Label.Text = 'Linkja Crypto Library: Dependency Installer and Generator'
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Point(65, 10)
#Main Form Bottom Label
$LabelBottom = New-Object $LabelObject
$LabelBottom.Text = 'A Free/Open Source Product of Cook County Health, linkja.github.io'
$LabelBottom.AutoSize = $true
$LabelBottom.Location = New-Object System.Drawing.Point(90, 270)


#Crypto Library Folder Name Input Box
$global:LibFolderNameForm = New-Object $FormObject
$global:LibFolderNameForm.ClientSize = '500,300'
$global:LibFolderNameForm.Text = 'Linkja Crypto'
$global:LibFolderNameForm.BackColor = "#aae5ff"
$global:LibFolderNameForm.StartPosition = 'CenterScreen'
$global:LibFolderNameForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::ExpandEnvironmentVariables('%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja.ico'))
$LibFolderLabel = New-Object $LabelObject
$LibFolderLabel.Text = 'Crypto Library Generated Successfully: Please Name the Project'
$LibFolderLabel.AutoSize = $true
$LibFolderLabel.Location = New-Object System.Drawing.Point(65, 10)
$global:LibFolderNameForm.Controls.Add($LibFolderLabel)
$LibFolderBtn = New-Object $ButtonObject
$LibFolderBtn.Text = 'Save Crypto Library'
$LibFolderBtn.BackColor = "#f6f6f4"
$LibFolderBtn.AutoSize = $true
$LibFolderBtn.Location = New-Object System.Drawing.Point(200,50)
$LibFolderBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
$global:LibFolderNameForm.AcceptButton = $LibFolderBtn
$global:LibFolderNameForm.Controls.Add($LibFolderBtn)
$global:LibFolderTextBox = New-Object $TextBoxObject
$global:LibFolderTextBox.Location = New-Object System.Drawing.Point(190,100)
$global:LibFolderTextBox.Size = New-Object System.Drawing.Size(260,20)
$global:LibFolderNameForm.Controls.Add($global:LibFolderTextBox)
$global:LibFolderNameForm.Topmost = $true
$global:LibFolderNameForm.Add_Shown({$global:LibFolderTextBox.Select()})

#Main Form Install Dependencies Button
function InstallDependencies { 
    $res = Start-Process -Wait -PassThru "${env:ProgramFiles(x86)}\Linkja\Linkja Crypto Installer\install_dependencies.exe" 
    $msgBox = New-Object -ComObject Wscript.Shell
    $msgBox.Popup("Linkja Dependency Installer is finished running. If it ran successfully, please reopen the Linkja Crypto application to build the Linkja Crypto library. If it failed, please try running it again or contact Linkja support.", 0, "Linkja Crypto", 0+64)
    [System.Environment]::Exit(0)
}
$global:BtnInstallDependencies = New-Object $ButtonObject
$global:BtnInstallDependencies.Text = 'Install Dependencies'
$global:BtnInstallDependencies.BackColor = "#f6f6f4"
$global:BtnInstallDependencies.AutoSize = $true
$global:BtnInstallDependencies.Location = New-Object System.Drawing.Point(200,50)
$global:BtnInstallDependencies.Add_Click({InstallDependencies})

#Build Linkja Crypto Button
function BuildLinkjaCrypto {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ref]$RefLibFolderNameForm,
        [Parameter(Mandatory=$true, Position=1)]
        [ref]$RefLibFolderTextBox
        )
    $CryptoDLLExisted = $false
    #Copy the existing DLL, if any, so it can be compared with the new DLL (if any) after batch script has run 
    if ((Test-Path -Path "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll") -eq 'True') {
        $CryptoDLLExisted = $true
        Copy-Item "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll" -Destination "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto_copy.dll" -Force
        
    }
    
    #Start Batch Script
    $proc = [Diagnostics.Process]::new()
    $proc.StartInfo.UseShellExecute = $true
    $proc.StartInfo.Verb = "runas"
    $res = $proc::Start( "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat","&& `"%ProgramFiles(x86)%\Linkja\Linkja Crypto Installer\linkja_compile.bat`"").WaitForExit(60)
    #Was build successful, and is new Crypto DLL file the same as old?
    $buildSuccess = $false
    if ((Test-Path -Path "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll") -eq 'True') {
        #no DLL before build script ran but there is a DLL now
        if ($CryptoDLLExisted -eq $false) {
            $buildSuccess = $true
        } else { 
            $newDLLHash = (Get-FileHash "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll").hash
            $prevDLLHash = (Get-FileHash "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto_copy.dll").hash
            if ($newDLLHash -ne $prevDLLHash) { #New DLL file must be different from prev. DLL file
                $buildSuccess = $true
            }
        }
        
    }
    if ($buildSuccess) {
        #create a new folder for Linkja Crypto Libraries if one does not exist
        if ((Test-Path "${env:ProgramFiles}\Linkja\CryptoLibraries\") -ne 'True') {
            New-Item -ItemType Directory -Path "${env:ProgramFiles}\Linkja\CryptoLibraries\"
            
        }
        $FormResult = $RefLibFolderNameForm.Value.ShowDialog()
        if ($FormResult -eq [System.Windows.Forms.DialogResult]::OK) {
            $NewDirPath = "${env:ProgramFiles}\Linkja\CryptoLibraries\" + $RefLibFolderTextBox.Value.Text + "\"
            New-Item -ItemType Directory -Path $NewDirPath
            Copy-Item "${env:ProgramFiles}\Linkja\linkja-crypto-master\src\linkjacrypto.dll" -Destination $NewDirPath + "\linkjacrypto.dll"
        }
        #open a form with a text box to name the subfolder where it will be kept.
    }
    

    #Redraw form after completion
    RedrawForm ([ref]$global:BtnInstallDependencies) ([ref]$global:BtnBuildLinkjaCrypto) ([ref]$global:BtnCleanupLinkjaCrypto) ([ref]$global:BtnOpenLinkjaFolder)
    $global:LinkjaCryptoForm.Refresh()
}
$global:BtnBuildLinkjaCrypto = New-Object $ButtonObject
$global:BtnBuildLinkjaCrypto.Text = 'Build Linkja Crypto Library'
$global:BtnBuildLinkjaCrypto.BackColor = "#f6f6f4"
$global:BtnBuildLinkjaCrypto.AutoSize = $true
$global:BtnBuildLinkjaCrypto.Location = New-Object System.Drawing.Point(190,100)
$global:BtnBuildLinkjaCrypto.Enabled = $false
$global:BtnBuildLinkjaCrypto.Add_Click({BuildLinkjaCrypto ([ref]$global:LibFolderNameForm) ([ref]$global:LibFolderTextBox)})


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

