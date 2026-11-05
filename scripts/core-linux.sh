#!/bin/bash
echo "========== INITIALIZATION OF DEV ENVIRONMENT LINUX =========="

# 1. Pembaruan Paket Dasar & Pemasangan GUI Ringan Resmi (XFCE + XRDP)
if [ "$OS_TYPE" = "ubuntu-latest" ] || [ "$OS_TYPE" = "debian-latest" ]; then
    sudo apt-get update -y
    sudo apt-get install -y xfce4 xfce4-goodies xrdp jq curl git python3 nodejs python3-pip
elif [ "$OS_TYPE" = "fedora-latest" ]; then
    sudo dnf update -y
    sudo dnf install -y xrdp xfce4-desktop jq curl git python3 nodejs
fi

# 2. Konfigurasi Autentikasi Pengguna Standar
sudo useradd -m -s /bin/bash "$RDP_USER"
echo "$RDP_USER:$RDP_PASS" | sudo chpasswd

# 3. Konfigurasi Sesi Display Grafis Resmi
echo "xfce4-session" > /home/$RDP_USER/.xsession
chown $RDP_USER:$RDP_USER /home/$RDP_USER/.xsession
sudo systemctl enable xrdp
sudo systemctl restart xrdp

# 4. Penyusunan Ruang Kerja Aplikasi
AppDir="/home/$RDP_USER/DevWorkspace"
mkdir -p "$AppDir"

if [ ! -z "$TARGET_REPO" ]; then
    cd "$AppDir"
    git clone "$TARGET_REPO" .

    if [ -f "requirements.txt" ]; then pip3 install -r requirements.txt; fi
    if [ -f "package.json" ]; then npm install; fi
fi

echo "Inisialisasi sistem Linux selesai."
