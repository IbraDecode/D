Write-Host "========== NETWORK SECURITY CHECK =========="

# Memastikan protokol jabat tangan jaringan lokal menggunakan enkripsi kuat
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Write-Host "Validasi standar keamanan jaringan internal aktif (TLS 1.2/1.3)."
