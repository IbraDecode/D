#!/usr/bin/env bash
set -Eeuo pipefail

echo "========== INITIALIZATION OF DEV ENVIRONMENT LINUX =========="

: "${RDP_USER:?RDP_USER wajib diisi}"
: "${RDP_PASS:?RDP_PASS wajib diisi}"
[[ "$RDP_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || { echo "RDP_USER tidak valid" >&2; exit 1; }

sudo apt-get update -y
sudo apt-get install -y xfce4 xfce4-goodies xrdp jq curl git python3 python3-pip nodejs npm

if ! id "$RDP_USER" >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash "$RDP_USER"
fi
printf '%s:%s\n' "$RDP_USER" "$RDP_PASS" | sudo chpasswd

printf '%s\n' xfce4-session | sudo tee "/home/$RDP_USER/.xsession" >/dev/null
sudo chown "$RDP_USER:$RDP_USER" "/home/$RDP_USER/.xsession"
sudo systemctl enable xrdp
sudo systemctl restart xrdp

app_dir="/home/$RDP_USER/DevWorkspace"
sudo install -d -o "$RDP_USER" -g "$RDP_USER" "$app_dir"
if [[ -n "${TARGET_REPO:-}" ]]; then
    [[ "$TARGET_REPO" =~ ^https://[^[:space:]]+$ ]] || { echo "TARGET_REPO harus URL HTTPS" >&2; exit 1; }
    if [[ -d "$app_dir/.git" ]]; then
        remote="$(git -C "$app_dir" remote get-url origin)"
        [[ "$remote" == "$TARGET_REPO" ]] || { echo "Workspace sudah berisi repositori lain" >&2; exit 1; }
    elif [[ -z "$(find "$app_dir" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
        sudo -u "$RDP_USER" git clone "$TARGET_REPO" "$app_dir"
    else
        echo "Workspace tidak kosong dan bukan repositori target" >&2
        exit 1
    fi
    if [[ -f "$app_dir/requirements.txt" ]]; then
        sudo apt-get install -y python3-venv
        sudo -u "$RDP_USER" python3 -m venv "$app_dir/.venv"
        sudo -u "$RDP_USER" "$app_dir/.venv/bin/pip" install -r "$app_dir/requirements.txt"
    fi
    if [[ -f "$app_dir/package.json" ]]; then
        sudo -u "$RDP_USER" npm --prefix "$app_dir" install
    fi
fi

echo "Inisialisasi sistem Linux selesai."
