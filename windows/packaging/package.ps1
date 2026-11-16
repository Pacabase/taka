# Usage: package.ps1 <version> <target, such as windows-x64>
# Packages the release folder as dist\Taka-<version>-<target>.zip and
# -setup.exe. Uses an installed Inno Setup 6, or downloads the pinned version.
param([Parameter(Mandatory)][string]$Version, [Parameter(Mandatory)][string]$Target)
$ErrorActionPreference = 'Stop'

Set-Location "$PSScriptRoot\..\.."
$release = "build\windows\$($Target -replace '^windows-', '')\runner\Release"
$innoSetup = '6.7.4'

foreach ($file in 'taka.exe', 'agent\bin\taka_agent.exe', 'vcruntime140.dll', 'agent\bin\vcruntime140.dll') {
  if (-not (Test-Path "$release\$file")) { throw "$release\$file is missing" }
}
Remove-Item -Recurse -Force build\package\Taka -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force build\package, dist | Out-Null
Copy-Item -Recurse $release build\package\Taka
Push-Location build\package
try {
  & 7z a -tzip "..\..\dist\Taka-$Version-$Target.zip" Taka
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
  Pop-Location
}

$iscc = (Get-Command ISCC.exe -ErrorAction SilentlyContinue).Source
if (-not $iscc) {
  $iscc = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $iscc) {
  $temp = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { [IO.Path]::GetTempPath() }
  $installer = "$temp\innosetup-$innoSetup.exe"
  Invoke-WebRequest "https://github.com/jrsoftware/issrc/releases/download/is-$($innoSetup -replace '\.', '_')/innosetup-$innoSetup.exe" -OutFile $installer
  if ((Get-FileHash $installer -Algorithm SHA256).Hash -ne 'a549929319f9120716677c685535ca4671e4b937b5fdc87e2585f32d8eb30e8c') {
    throw "innosetup-$innoSetup.exe doesn't match its checksum"
  }
  $inno = "$temp\inno-$innoSetup"
  $setup = Start-Process $installer -Wait -PassThru -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', "/DIR=$inno"
  if ($setup.ExitCode -ne 0) { throw "innosetup-$innoSetup.exe failed with exit code $($setup.ExitCode)" }
  $iscc = "$inno\ISCC.exe"
}

& $iscc "/DVersion=$Version" "/DSource=$PWD\build\package\Taka" "/DOutput=$PWD\dist" windows\packaging\taka.iss
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
