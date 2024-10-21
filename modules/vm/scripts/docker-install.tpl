#!/bin/bash
echo '========================================================'
echo '=== STEP 1: DOCKER PRE REQUIREMENTS ==='
echo '========================================================'
sudo apt-get update
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
unzip \
gnupg-agent \
software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
echo '=============================================================='
echo '=== STEP 2: ADD REPO FOR DOCKER INSTALATION ==='
echo '=============================================================='
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
echo '====================================='
echo '=== STEP 3: DOCKER INSTALLATION ==='
echo '====================================='
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
echo '============================================='
echo '=== STEP 4: DOCKER-COMPOSE INSTALLATION ==='
echo '============================================='
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo '==============================================================='
echo '=== STEP 5: START DOCKER AT OPERATING SYSTEM STARTUP ==='
echo '==============================================================='
sudo systemctl enable docker
echo '========================================================='
echo '=== STEP 6: ADD CURRENT USER TO DOCKER GROUP ==='
echo '========================================================='
sudo usermod -aG docker ubuntu
echo '========================================='
echo '=== STEP 7: INSTALL CTOP TOOL ==='
echo '========================================='
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
echo "deb http://packages.azlux.fr/debian/ stable main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo apt update
sudo apt install -y docker-ctop
ctop -v