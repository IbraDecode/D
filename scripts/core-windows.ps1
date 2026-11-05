Write-Host "========== INITIALIZATION OF DEV ENVIRONMENT WINDOWS =========="

# 1. Alokasi Virtual Memory Secara Standar (Bukan untuk bypass limits)
Set-CimInstance -Query "Select * from Win32_PageFileSetting" -Property @{InitialSize = 8192; MaximumSize = 16384} -ErrorAction SilentlyContinue

# 2. Mengaktifkan Remote Desktop (RDP) Melalui Jalur Resmi
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 3. Membuat Pengguna Lingkungan Kerja Standar
if ([string]::IsNullOrWhiteSpace($env:RDP_USER) -or [string]::IsNullOrEmpty($env:RDP_PASS)) {
    throw "RDP_USER dan RDP_PASS wajib diisi."
}
if ($env:RDP_USER -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,19}$') {
    throw "RDP_USER tidak valid."
}
$SecPassword = ConvertTo-SecureString $env:RDP_PASS -AsPlainText -Force
if (-not (Get-LocalUser -Name $env:RDP_USER -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $env:RDP_USER -Password $SecPassword -Description "Development User Account" | Out-Null
} else {
    Set-LocalUser -Name $env:RDP_USER -Password $SecPassword
}
if (-not (Get-LocalGroupMember -Group "Remote Desktop Users" -ErrorAction SilentlyContinue | Where-Object Name -Like "*\$($env:RDP_USER)")) {
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $env:RDP_USER
}

# 4. Instalasi Perangkat Lunak Resmi Menggunakan Package Manager
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    throw "Chocolatey tidak tersedia pada runner Windows."
}
Write-Host "Menginstal peralatan pengembangan dasar..."
choco install git python nodejs.install -y --no-progress
if ($LASTEXITCODE -ne 0) { throw "Instalasi paket Chocolatey gagal dengan kode $LASTEXITCODE." }
Get-Command git, python, node, npm -ErrorAction Stop | Out-Null

# 5. Sinkronisasi Ruang Kerja Proyek (Workspace Setup)
$AppDir = "C:\Users\Public\DevWorkspace"
New-Item -ItemType Directory -Path $AppDir -ErrorAction SilentlyContinue | Out-Null

if (-not [string]::IsNullOrWhiteSpace($env:TARGET_REPO)) {
    if ($env:TARGET_REPO -notmatch '^https://\S+$') { throw "TARGET_REPO harus URL HTTPS." }
    if (Test-Path (Join-Path $AppDir ".git")) {
        $remote = git -C $AppDir remote get-url origin
        if ($LASTEXITCODE -ne 0 -or $remote.Trim() -ne $env:TARGET_REPO) { throw "Workspace sudah berisi repositori lain." }
    } elseif ((Get-ChildItem -Force $AppDir | Measure-Object).Count -eq 0) {
        git clone $env:TARGET_REPO $AppDir
        if ($LASTEXITCODE -ne 0) { throw "Clone TARGET_REPO gagal." }
    } else {
        throw "Workspace tidak kosong dan bukan repositori target."
    }

    Push-Location $AppDir
    try {
        if (Test-Path "requirements.txt") { python -m pip install -r requirements.txt; if ($LASTEXITCODE -ne 0) { throw "Instalasi requirements.txt gagal." } }
        if (Test-Path "package.json") { npm install; if ($LASTEXITCODE -ne 0) { throw "npm install gagal." } }
    } finally { Pop-Location }
}

Write-Host "Inisialisasi sistem Windows selesai."
