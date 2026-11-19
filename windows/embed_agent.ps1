# Usage: embed_agent.ps1 <flutter root> <target platform> <destination> <build configuration>
param([string]$FlutterRoot, [string]$Platform, [string]$Destination, [string]$Configuration)
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

# Windows can't replace a running agent, such as one a previous run left.
$folder = [IO.Path]::GetFullPath($Destination).TrimEnd('\') + '\'
# CMake may run a 32-bit PowerShell, where Get-Process has no 64-bit program's path.
$running = Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($folder, 'OrdinalIgnoreCase') }
$running | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
$running | ForEach-Object { Wait-Process -Id $_.ProcessId -Timeout 10 -ErrorAction SilentlyContinue }
if (Test-Path $Destination) { Remove-Item -Recurse -Force $Destination }
New-Item -ItemType Directory -Force $Destination | Out-Null
Copy-Item -Recurse "$bundle\bin", "$bundle\lib" $Destination
# Task Manager shows a program without a description by its file name.
Rename-Item "$Destination\bin\taka_agent.exe" Taka.exe
Copy-Item "$agent\assets\*.png" $Destination
# Must match TakaBuild.
$appId = if ($Configuration -eq 'Release') { 'com.pacabase.taka' } else { 'com.pacabase.taka.dev' }
Set-Content -NoNewline -Path "$Destination\app_id" -Value $appId
