# LinkjaCryptoInstaller

## Building
LinkjaCryptoInstaller installs the Linkja Crypto GUI, which itself enables the user to install required dependencies for building the Linkja Crypto library and run the Linkja Crypto library itself.

## Program Use
Download the Windows Installer (.msi) file and run it on a Windows 10 PC. Administrator privileges are required. This installs a link to the Linkja Crypto GUI in the Start Menu.

Go to Linkja -> Linkja Crypto in the Start Menu and click the "Install Dependencies" button.

A command line window will open, running a script that downloads from the Internet and installs required programs to compile the Linkja Crypto library. Once the required programs are downloaded, Visual Studio will be installed (you will be prompted to press Enter to initiate the installation). The Visual Studio installer window will open--please do not change any settings, as the correct components are already checked. Click the "Install" or "Continue" buttons as appropriate.

The Dependency Installer will finish, and the Linkja Crypto GUI will then close.
Re-open it and click the "Build Linkja Crypto Library" to compile the unique `linkjacrypto.dll` library for your project. Each time this button is clicked, it deletes the previous `linkjacrypto.dll` file and compiles a new, unique one.                

## Components
### Linkja Crypto GUI
`LinkjaCrypto.ps1` is the PowerShell source code for the GUI, built using .NET Windows Forms in PowerShell. This compiles to `LinkjaCryptoGUI.exe` using the `PS2EXE` tool, which you may need to install before using.   
Compile as below: `Invoke-PS2EXE .\LinkjaCrypto.ps1 .\LinkjaCryptoGUI.exe -requireAdmin`

This runs the Dependency Installer, Linkja Crypto Library compiler, and also contains code to clean up the compiled library and go to the `linkjacrypto.dll` containing folder.

### Dependency Installer
`install_dependencies.ps1` is the PowerShell source code to downland and install all Linkja dependencies. It compiles to `install_dependencies.exe` using the `PS2EXE` tool, as above.  
Since the Dependency Installer is downloading components from the Internet, download links regularly fail and need to be updated often.

### Linkja Crypto Library Compiler
`linkja_compile.bat` is a batch file that compiles the Linkja Crypto library.

### WiX Windows Installer
Built and compiled using Visual Studio 2022 with WiX installer components. The packaged configuration files should be sufficient to build the installer.
