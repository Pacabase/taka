; Usage: iscc /DVersion=<version> /DSource=<the Taka folder> /DOutput=<folder> taka.iss

[Setup]
AppId={{9A17E328-29FD-4F68-B088-6F5476D30B9B}
AppName=Taka
AppVersion={#Version}
AppPublisher=Pacabase
AppPublisherURL=https://github.com/Pacabase/taka
AppSupportURL=https://github.com/Pacabase/taka/issues
PrivilegesRequired=lowest
DefaultDirName={autopf}\Taka
DisableProgramGroupPage=yes
DisableDirPage=auto
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#Output}
OutputBaseFilename=Taka-{#Version}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\taka.exe
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
CloseApplications=force

[InstallDelete]
Type: filesandordirs; Name: "{app}\agent"
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "{#Source}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Taka"; Filename: "{app}\taka.exe"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueName: "com.pacabase.taka.agent"; ValueType: none; Flags: uninsdeletevalue

[Run]
Filename: "{app}\taka.exe"; Description: "Open Taka"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; This install's taka.exe and Taka.exe only, not the uninstaller beside them, found by the working directory so
; no quote in the path breaks it, through Win32_Process since a 32-bit uninstaller's Get-Process has no 64-bit path.
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -Command ""$folder = (Get-Location).Path + '\'; Get-CimInstance Win32_Process | Where-Object {{ $_.Name -eq 'taka.exe' -and $_.ExecutablePath.StartsWith($folder, 'OrdinalIgnoreCase') } | ForEach-Object {{ Stop-Process -Id $_.ProcessId -Force }"""; WorkingDir: "{app}"; Flags: runhidden; RunOnceId: "StopTaka"
