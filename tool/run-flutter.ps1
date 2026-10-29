# Helper to run flutter/dart with a minimal PATH on machines where the user
# PATH is bloated (>8KB), which breaks flutter.bat's internal `WHERE /Q git`
# lookup (cmd.exe truncates the inherited PATH and `where.exe` falls off).
#
# Usage:
#   powershell -File tool\run-flutter.ps1 analyze
#   powershell -File tool\run-flutter.ps1 test test\app_config_store_test.dart
#   powershell -File tool\run-flutter.ps1 <any flutter args...>
#
# Forwards all args to `flutter` and preserves the exit code.

$ErrorActionPreference = 'Continue'

# Minimal PATH: Flutter SDK, Dart, Git, Windows system dirs (where.exe, cmd),
# and PowerShell (flutter.bat needs PowerShell.exe to run shared.ps1).
$flutterBin = Split-Path -Parent (Get-Command flutter.bat -ErrorAction Stop).Source
$cleanPath = @(
    $flutterBin,
    'C:\Program Files\Git\cmd',
    'C:\Windows\System32',
    'C:\Windows',
    'C:\Windows\System32\Wbem',
    'C:\Windows\System32\WindowsPowerShell\v1.0',
    'C:\Windows\System32\OpenSSH'
) -join ';'

$env:PATH = $cleanPath
$env:GIT_INSTALL_ROOT = $null  # avoid any git shim interference

& flutter.bat @args
exit $LASTEXITCODE
