Write-Host "========== DIAGNOSTIC MANAGEMENT ENGINE =========="

# Menolak pengiriman data diagnostik tambahan ke pihak ketiga secara standar
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
Set-ItemProperty -Path $Path -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue

Write-Host "Pengaturan manajemen data diagnostik telah diterapkan."
