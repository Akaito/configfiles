#!/usr/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install -y git

# configfiles
git clone git@github.com:Akaito/configfiles.git
pushd configfiles
make git
make vim
popd

# room-assistant
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
    sudo apt-get install -y nodejs

