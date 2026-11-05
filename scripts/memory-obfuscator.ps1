Write-Host "========== INTEGRATED WORKLOAD SIMULATOR (RAM) =========="

# Melakukan simulasi alokasi beban memori berkala untuk menguji stabilitas swap file
for ($k = 0; $k -lt 5; $k++) {
    Write-Host "Menguji stabilitas RAM dengan alokasi objek transien..."
    $TestArray = New-Object Byte[] 50MB
    Start-Sleep -Seconds 10
    $TestArray = $null
    [System.GC]::Collect()
    Start-Sleep -Seconds 20
}

Write-Host "Siklus uji beban memori (Stress-Test) selesai."
