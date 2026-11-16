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

# Task Manager names a program by its description, which `dart build cli`
# leaves out.
$rcedit = "$PSScriptRoot\..\build\rcedit-2.0.0-x64.exe"
if (-not (Test-Path $rcedit)) {
  New-Item -ItemType Directory -Force (Split-Path $rcedit) | Out-Null
  Invoke-WebRequest https://github.com/electron/rcedit/releases/download/v2.0.0/rcedit-x64.exe -OutFile $rcedit
}
if ((Get-FileHash $rcedit -Algorithm SHA256).Hash -ne '3e7801db1a5edbec91b49a24a094aad776cb4515488ea5a4ca2289c400eade2a') {
  Remove-Item $rcedit
  Write-Error "rcedit's checksum doesn't match"
}
& $rcedit "$bundle\bin\taka_agent.exe" --set-version-string FileDescription Taka --set-version-string ProductName Taka
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item -Recurse -Force $Destination -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Destination | Out-Null
Copy-Item -Recurse "$bundle\bin", "$bundle\lib" $Destination
Copy-Item "$agent\assets\*.png" $Destination
