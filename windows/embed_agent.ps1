# Usage: embed_agent.ps1 <flutter root> <target platform> <destination>
param([string]$FlutterRoot, [string]$Platform, [string]$Destination)
$ErrorActionPreference = 'Stop'

$dart = "$FlutterRoot\bin\cache\dart-sdk\bin\dart.exe"
$agent = "$PSScriptRoot\..\packages\agent"
$bundle = "$agent\build\cli\$($Platform -replace '-', '_')\bundle"

# Without the old builds, one for another chip can't pass the check below.
Remove-Item -Recurse -Force "$agent\build\cli" -ErrorAction SilentlyContinue
Push-Location $agent
try {
  & $dart pub get
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  & $dart build cli
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
  Pop-Location
}
if (-not (Test-Path "$bundle\bin\taka_agent.exe")) {
  Write-Error "The app is built for $Platform, but Dart builds the agent only for this machine"
}

# A console program opens a console window when Windows starts it at login, so
# mark it a GUI one (subsystem 2).
$executable = "$bundle\bin\taka_agent.exe"
$bytes = [IO.File]::ReadAllBytes($executable)
$subsystem = [BitConverter]::ToInt32($bytes, 0x3C) + 0x5C
$bytes[$subsystem] = 2
[IO.File]::WriteAllBytes($executable, $bytes)

Remove-Item -Recurse -Force $Destination -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Destination | Out-Null
Copy-Item -Recurse "$bundle\bin", "$bundle\lib" $Destination
Copy-Item "$agent\assets\*.png" $Destination
