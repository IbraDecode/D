Write-Host "========== STORAGE CLEANUP MANAGEMENT =========="

# Membersihkan folder temporary publik secara berkala untuk menjaga kapasitas disk
$TempDir = "C:\Users\Public\DevWorkspace\.tmp_cache"
if (Test-Path $TempDir) {
    Write-Host "Membersihkan berkas temporer lama..."
    Remove-Item -Path "$TempDir\*" -Force -Recurse -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $TempDir -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "Siklus pembersihan dan perawatan media penyimpanan selesai."
