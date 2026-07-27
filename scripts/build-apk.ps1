$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

flutter build apk --release

$version = (Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(\S+)" | ForEach-Object { $_.Matches[0].Groups[1].Value })
$versionName = $version.Split("+")[0]
$src = "build\app\outputs\flutter-apk\app-release.apk"
$dst = "build\app\outputs\flutter-apk\ryadom-$versionName.apk"

Copy-Item $src $dst -Force
Write-Host ""
Write-Host "APK: $((Resolve-Path $dst).Path)"