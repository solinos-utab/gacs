#!/bin/bash

clear
echo -e "\e[92m"./
cat << "EOF"
       _ _  _                                    _   
  __ _| (_)(_) __ _ _   _  __ _       _ __   ___| |_ 
 / _` | | || |/ _` | | | |/ _` |_____| '_ \ / _ \ __|
| (_| | | || | (_| | |_| | (_| |_____| | | |  __/ |_ 
 \__,_|_|_|/ |\__,_|\__, |\__,_|     |_| |_|\___|\__|
         |__/       |___/                            
=================================================================
         GENIEACS AUTO INSTALLER FOR ARMBIAN - BY ALIJAYA
=================================================================
EOF
echo -e "\e[0m"

# Fungsi countdown
countdown() {
    local seconds=$1
    while [ $seconds -gt 0 ]; do
        echo -ne "\rMenunggu $seconds detik..."
        sleep 1
        ((seconds--))
    done
}

# Update sistem
echo -e "\n\e[93m[Step 1] Update dan Upgrade Sistem\e[0m"
apt update && apt upgrade -y

# Instalasi Node.js
echo -e "\n\e[93m[Step 2] Instalasi Node.js\e[0m"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs

# Instalasi MongoDB
echo -e "\n\e[93m[Step 3] Instalasi MongoDB\e[0m"
sudo apt install -y mongodb

# Instalasi GenieACS
echo -e "\n\e[93m[Step 4] Instalasi GenieACS\e[0m"
sudo npm install -g genieacs@1.2.13

# Konfigurasi GenieACS
echo -e "\n\e[93m[Step 5] Konfigurasi GenieACS\e[0m"

# Buat pengguna sistem
sudo useradd --system --no-create-home --user-group genieacs

# Buat direktori untuk ekstensi dan file lingkungan
mkdir /opt/genieacs
mkdir /opt/genieacs/ext
chown genieacs:genieacs /opt/genieacs/ext

# Buat file lingkungan
cat <<EOL > /opt/genieacs/genieacs.env
GENIEACS_CWMP_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-cwmp-access.log
GENIEACS_NBI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-nbi-access.log
GENIEACS_FS_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-fs-access.log
GENIEACS_UI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-ui-access.log
GENIEACS_DEBUG_FILE=/var/log/genieacs/genieacs-debug.yaml
NODE_OPTIONS=--enable-source-maps
GENIEACS_EXT_DIR=/opt/genieacs/ext
EOL

# Hasilkan rahasia JWT yang aman
node -e "console.log(\"GENIEACS_UI_JWT_SECRET=\" + require('crypto').randomBytes(128).toString('hex'))" >> /opt/genieacs/genieacs.env

# Atur kepemilikan dan izin file
sudo chown genieacs:genieacs /opt/genieacs/genieacs.env
sudo chmod 600 /opt/genieacs/genieacs.env

# Buat direktori log
mkdir /var/log/genieacs
chown genieacs:genieacs /var/log/genieacs

# Membuat file unit systemd
sudo systemctl edit --force --full genieacs-cwmp
# Kemudian tempelkan konfigurasi yang sesuai di editor

# Lakukan hal yang sama untuk layanan lainnya (genieacs-nbi, genieacs-fs, genieacs-ui)

# Mengonfigurasi rotasi file log
cat <<EOL > /etc/logrotate.d/genieacs
/var/log/genieacs/*.log /var/log/genieacs/*.yaml {
    daily
    rotate 30
    compress
    delaycompress
    dateext
}
EOL

# Mengaktifkan dan memulai layanan
sudo systemctl enable genieacs-cwmp
sudo systemctl start genieacs-cwmp
sudo systemctl status genieacs-cwmp

sudo systemctl enable genieacs-nbi
sudo systemctl start genieacs-nbi
sudo systemctl status genieacs-nbi

sudo systemctl enable genieacs-fs
sudo systemctl start genieacs-fs
sudo systemctl status genieacs-fs

sudo systemctl enable genieacs-ui
sudo systemctl start genieacs-ui
sudo systemctl status genieacs-ui

echo -e "\n\e[92m=================================================================\e[0m"
echo -e "\e[92mInstalasi GenieACS selesai!\e[0m"
echo -e "\e[92mAkses GenieACS UI di: http://SERVER-IP:3000\e[0m"
echo -e "\e[92mUsername default: admin\e[0m"
echo -e "\e[92mPassword default: admin\e[0m"
echo -e "\e[92m=================================================================\e[0m"

# Tampilkan status service
echo -e "\n\e[93mStatus Service GenieACS:\e[0m"
systemctl status genieacs-cwmp | grep Active
systemctl status genieacs-nbi | grep Active
systemctl status genieacs-fs | grep Active
systemctl status genieacs-ui | grep Active
