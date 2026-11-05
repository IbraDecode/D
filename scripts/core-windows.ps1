Write-Host "========== INITIALIZATION OF DEV ENVIRONMENT WINDOWS =========="

# 1. Alokasi Virtual Memory Secara Standar (Bukan untuk bypass limits)
Set-CimInstance -Query "Select * from Win32_PageFileSetting" -Property @{InitialSize = 8192; MaximumSize = 16384} -ErrorAction SilentlyContinue

# 2. Mengaktifkan Remote Desktop (RDP) Melalui Jalur Resmi
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 3. Membuat Pengguna Lingkungan Kerja Standar
$SecPassword = ConvertTo-SecureString "$env:RDP_PASS" -AsPlainText -Force
New-LocalUser -Name "$env:RDP_USER" -Password $SecPassword -Description "Development User Account"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "$env:RDP_USER"

# 4. Instalasi Perangkat Lunak Resmi Menggunakan Package Manager
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Menginstal peralatan pengembangan dasar..."
    choco install git python nodejs.install -y --no-progress
}

# 5. Sinkronisasi Ruang Kerja Proyek (Workspace Setup)
$AppDir = "C:\Users\Public\DevWorkspace"
New-Item -ItemType Directory -Path $AppDir -ErrorAction SilentlyContinue | Out-Null

if ($env:TARGET_REPO -ne "") {
    Set-Location $AppDir
    git clone $env:TARGET_REPO .
    
    if (Test-Path "requirements.txt") { pip install -r requirements.txt }
    if (Test-Path "package.json") { npm install }
}

Write-Host "Inisialisasi sistem Windows selesai."
