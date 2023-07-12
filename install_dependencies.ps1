#Requires -RunAsAdministrator

function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

Read-Host -Prompt "Welcome to the Linkja Crypto library dependencies installer. You will need a minimum of 12 GB of free space to install the Linkja Crypto Library dependencies, and it will take about one hour. To proceed, press Enter. Otherwise, click the x button in the top right corner to close this installer."
#$InitialPath = Get-ScriptDirectory
if ((Test-Path -Path "$Env:Programfiles\Linkja") -eq $false) {
    New-Item -Path "$Env:Programfiles\Linkja\" -ItemType Directory
}
Set-Location -Path "$Env:Programfiles\Linkja\"

#Copy Batch Files for Compilation and Cleanup to correct directory
#Copy-Item "$InitialPath\linkja_compile.bat" "$Env:Programfiles\Linkja\linkja_compile.bat"
#Copy-Item "$InitialPath\linkja_cleanup.bat" "$Env:Programfiles\Linkja\linkja_cleanup.bat"

function Get-LinkjaInstaller {
    param (
        [string]$ProgramName,
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $FileAlreadyExists = (Test-Path -Path $DestinationPath -PathType leaf)
    if ($FileAlreadyExists) {
        Remove-Item $DestinationPath
    }
    try {
        "Downloading $ProgramName..."
        Invoke-WebRequest -Uri $SourcePath -OutFile $DestinationPath
        "$ProgramName downloaded successfully."
    } catch {
        Read-Host -Prompt "$ProgramName failed to download. You may be experiencing internet connection difficulties. Please try running the installer again. If the problem persists, contact Linkja support with this message. Press Enter to exit"
        exit
    }

}
function Read-PrevInstalled {
    param (
        [string]$ProgramName,
        [string]$PrevInstalled
    )

    if ($PrevInstalled -eq 'True') {
        $Confirmation = Read-Host "$ProgramName was previously installed on this computer. Choose y to override and install anyway (recommended) or n to quit installer. If you're unsure what to do, please contact Linkja support."
        if ($Confirmation -eq 'n') {
            exit
        }
    }
}

#Download Components (So we can fail before spending 30 minutes installing Visual Studio if there are download issues)
$CMockaPrevInstalled = (Get-ChildItem -Path ${Env:ProgramFiles(x86)} -Filter cmocka -ErrorAction SilentlyContinue -Force).Length -gt 0
Read-PrevInstalled "CMocka" $CMockaPrevInstalled 
$CMockaDestPath = "$Env:Programfiles\Linkja\cmocka-1.1.0-msvc.exe" 
Get-LinkjaInstaller "CMocka" "https://cmocka.org/files/1.1/cmocka-1.1.0-msvc.exe" $CMockaDestPath

$OpenJDKPrevInstalled = ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match "Eclipse Temurin JDK").Length -gt 0
Read-PrevInstalled "Eclipse Temurin JDK" $OpenJDKPrevInstalled 
$OpenJDKDestPath = "$Env:Programfiles\Linkja\OpenJDK11U-jdk_x64_windows_hotspot_11.0.17_8.msi"
Get-LinkjaInstaller "Eclipse Temurin JDK" "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.17%2B8/OpenJDK11U-jdk_x64_windows_hotspot_11.0.17_8.msi" $OpenJDKDestPath

$OpenSSLPrevInstalled = ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match "OpenSSL").Length -gt 0
Read-PrevInstalled "OpenSSL" $OpenSSLPrevInstalled 
$OpenSSLDestPath = "$Env:Programfiles\Linkja\Win64OpenSSL-1_1_1u.msi" 
Get-LinkjaInstaller "OpenSSL" "https://slproweb.com/download/Win64OpenSSL-1_1_1u.msi" $OpenSSLDestPath

$LinkjaCryptoDestPath = "$Env:Programfiles\Linkja\master.zip"
Get-LinkjaInstaller "Linkja Crypto Source Code" "https://github.com/linkja/linkja-crypto/archive/refs/heads/master.zip" $LinkjaCryptoDestPath

$VSPrevInstalled = (Get-ChildItem -Path ${Env:ProgramFiles} -Filter "Microsoft Visual Studio" -ErrorAction SilentlyContinue -Force).Length -gt 0
Read-PrevInstalled "Microsoft Visual Studio" $VSPrevInstalled 
$VSDestPath = "$Env:Programfiles\Linkja\vs_community.exe"
Get-LinkjaInstaller "Visual Studio Installer" "https://aka.ms/vs/17/release/vs_community.exe" $VSDestPath

# Install Visual Studio 2022 https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=vs-2022&preserve-view=true 
$VSArgumentList = "--wait --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NativeCrossPlat --includeRecommended"
# previously had --quiet and --includeOptional

Read-Host -Prompt "Ready to install Microsoft Visual Studio. Press Enter, and a window will open. Click the Install or Continue buttons as prompted, without changing any selections. The install may take a few minutes, or up to an hour depending on the speed of your Internet connection. Press Enter to continue."
"Installing Visual Studio. You will need to close the Visual Studio Installer window and `"Sign In to Visual Studio`" window when installation completes. Then click here and Press Enter to continue Linkja Crypto installation."
try {
    Start-Process -FilePath $VSDestPath -Wait -ArgumentList $VSArgumentList
} catch {
    Read-Host -Prompt "Visual Studio install failed. Please contact Linkja support with any error messages you may have received above. Press Enter to exit"
    exit
}
"Visual Studio Install Complete"

#Install CMocka
"Installing CMocka..."
try {
    Start-Process -Wait -FilePath $CMockaDestPath -ArgumentList "/S"
} catch {
    Read-Host -Prompt "CMocka install failed. Please contact Linkja support with any error messages you may have received above. Press Enter to exit"
    exit
}
"CMocka Install Complete"

#Install Eclipse Temurin JDK 11 https://github.com/adoptium/installer/blob/master/wix/README.md for documentation
"Installing Eclipse Temurin JDK..."
try {
    #Start-Process -Wait -FilePath msiexec -ArgumentList /i $OpenJDKDestPath 'ADDLOCAL="FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft"', 'INSTALLDIR="$Env:Programfiles\Java\jdk-11\"' /quiet /norestart -Verb RunAs
    $AddLocal = "FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft"
    $InstallDir = "$Env:Programfiles\Java\jdk-11\" 
    Start-Process -Wait -FilePath $OpenJDKDestPath -ArgumentList "/q ADDLOCAL=`"$AddLocal`" INSTALLDIR=`"$InstallDir`""
} catch {
    Read-Host -Prompt "Eclipse Temurin JDK install failed. Please contact Linkja support with any error messages you may have received above. Press Enter to exit"
    exit
}
"Eclipse Temurin JDK Install Complete"

#Install OpenSSL
"Installing OpenSSL..."
try {
    Start-Process -Wait -FilePath $OpenSSLDestPath -ArgumentList "/quiet"
} catch {
    Read-Host -Prompt "OpenSSL install failed. Please contact Linkja support with any error messages you may have received above. Press Enter to exit"
    exit
}
"OpenSSL Install Complete"

#Download Linkja Crypto Library and extract
"Extracting Linkja Crypto Source Code"
try {
    Expand-Archive -Path $LinkjaCryptoDestPath -DestinationPath "$Env:Programfiles\Linkja"
} catch {
    Read-Host -Prompt "Linkja Crypto Source Code ZIP file extraction failed. Please contact Linkja support with any error messages you may have received above. Press Enter to exit"
    exit
}
"Linkja Crypto Source Code Successfully Extracted"

"Linkja Crypto Library Generator has been installed. Please restart your computer to apply software settings."
New-Item "${env:ProgramFiles(x86)}\Linkja\Linkja Crypto Installer\dependencies_installed.txt"
exit

