#!/bin/bash

sudo apt update

# ----------
# Core Tools
# ----------

echo Installing core tools...

sudo apt install -y thunderbird thunderbird-l10n-de keepassxc syncthing build-essential git unzip curl

echo Enabling syncthing service...

systemctl --user enable --now syncthing.service

# -------
# git
# -------

read -p "Enter your email address for git... " email

git config --global user.email "$email"
git config --global user.name "Michael Freimüller"

# -------
# Flatpak
# -------

echo Installing flatpak...

sudo apt install -y flatpak plasma-discover-backend-flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ----------
# kvm
# ----------

echo Installing kvm...

sudo apt install qemu-system libvirt-daemon-system

adduser $USER libvirt

# ----------
# LaTeX
# ----------

echo Installing LaTeX...

sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-xetex texlive-luatex

#
# Docker
#

read -p "Do you want to setup docker? [y/N] " answer
answer=${answer,,}

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then

# Source: https://docs.docker.com/engine/install/debian/#install-using-the-repository

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

curl -L -O https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo dpkg -i docker-desktop-amd64.deb
rm docker-desktop-amd64.deb

sudo apt install -f

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

gpg --batch --generate-key <<EOF
Key-Type: ed25519
Key-Usage: sign
Subkey-Type: cv25519
Name-Real: Michael Freimüller
Name-Email: $email
Expire-Date: 3y
%commit
EOF

GPG_ID=$(gpg --list-secret-keys --with-colons | awk -F: '/^sec/{print $5}' | tail -n1)

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

sudo apt install -f # We might need to fix dependencies for steam

fi

echo Finished setup script. Please restart your computer.
