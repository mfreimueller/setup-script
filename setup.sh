#!/bin/bash

sudo apt update

# ----------
# Core Tools
# ----------

echo Installing core tools...

sudo apt install -y thunderbird thunderbird-l10n-de keepassxc syncthing build-essential git unzip curl gimp inkscape python3-venv python3-pip apt-transport-https

sudo apt remove --purge -y kmail korganizer konqueror
sudo apt autoremove -y

echo Enabling syncthing service...

systemctl --user enable --now syncthing.service

# -------
# fstrim timer
# -------

sudo systemctl enable --now fstrim.timer

# -------
# git
# -------

read -p "Enter your email address for git... " email

git config --global user.email "$email"
git config --global user.name "Michael Freimüller"
git config --global pull.rebase false

# --------
# konsave
# --------

read -p "Do you want to import the KDE profile? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

python3 -m venv /tmp/konsave
source /tmp/konsave/bin/activate
pip install setuptools
pip install konsave

konsave -i files/kde_profile.knsv

deactivate

rm -rf /tmp/konsave

fi

# --------
# Firefox AddOns
# --------

read -p "Do you want to setup the Firefox addons? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

sudo mkdir -p /etc/firefox/policies
sudo cp files/policies.json /etc/firefox/policies

fi

# --------
# OnlyOffice
# --------

read -p "Do you want to install OnlyOffice? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

sudo apt remove --purge -y libreoffice-*
sudo apt -y autoremove

curl -L -O https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb
sudo dpkg -i onlyoffice-desktopeditors_amd64.deb
rm onlyoffice-desktopeditors_amd64.deb

sudo apt install -y -f

fi

# -------
# Flatpak
# -------

echo Installing flatpak...

sudo apt install -y flatpak plasma-discover-backend-flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ----------
# kvm
# ----------

read -p "Do you want to setup kvm/qemu? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

echo Installing kvm...

sudo apt install -y qemu-system libvirt-daemon-system virt-manager

sudo adduser $USER libvirt

sudo virsh net-autostart default

read -p "Do you want to import the Windows 11 VM config? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

sudo virsh define --file files/Win_11.xml

fi

fi

# ----------
# LaTeX
# ----------

echo Installing LaTeX...

sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-xetex texlive-luatex

#  ----------
# Docker
# -----------

read -p "Do you want to setup docker? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

# Source: https://docs.docker.com/engine/install/debian/#install-using-the-repository

# Add Docker's official GPG key:
sudo apt update
sudo apt -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

curl -L -O https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo dpkg -i docker-desktop-amd64.deb
rm docker-desktop-amd64.deb

sudo apt install -y -f

fi

# ----------
# CoolerControl
# ----------

read -p "Do you want to setup CoolerControl? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

curl -1sLf \
  'https://dl.cloudsmith.io/public/coolercontrol/coolercontrol/setup.deb.sh' \
  | sudo -E bash

sudo apt update
sudo apt install -y coolercontrol

sudo systemctl enable --now coolercontrold

fi

# ----------
# SSH keys
# ----------

read -p "Do you want to setup your ssh key? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

echo Setting up ssh keys...

mkdir ~/.ssh
pushd ~/.ssh
ssh-keygen -t rsa
popd

fi

# ----------
# GPG key
# ----------

read -p "Do you want to setup your gpg key? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

echo "Follow the instructions on screen..."

gpg --generate-key

read -p "Now enter the generated GPG ID and press ENTER: " GPG_ID

pass init "$GPG_ID"

fi

# ----------
# game tools
# ----------

read -p "Do you want to install game tools? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

echo Installing game tools

sudo apt install -y gamemode

curl -O -L https://cdn.akamai.steamstatic.com/client/installer/steam.deb
sudo dpkg -i steam.deb
rm -f steam.deb

sudo apt install -y -f # We might need to fix dependencies for steam

fi

echo Finished setup script. Please restart your computer.
