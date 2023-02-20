#!/bin/bash

set -x
set -e

echo "Setting up the deployment environment. If an error occurs, manually fix the cause of it and continue executing commands from the script from the point where you left off"

PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHaHzyMRWZtbv1JZ6kTDbZGVpKYD+kQdccV61FkI8/RpMmUJexPg4hw44gZ+65VkIg64GqFXVSLnX2hXa8NFRvzsB3cTbur94+HH3N1/KDApklcNQa3xpp69mh57VVOqixcjtIrX33WIhG0u/QfiqlNe759KRbNFo3A9aBvsqoyKo74Pi1nJoHAozyft8Sm/PhjtWPyaJSrLfmThwXBrBAZVzBMbhu02sfUelC/9B5sTwCFsOlIUMlrSWWop6CMjnk+JdGe78VIrBgAyzUQoXXsDsVf0mA5GqDGZiATMBDyTBX+f8JAaYgns/CpX/tb4wnxJKUCtcJtfI328aNBl5T george@george-workstation-x1"

ROOT_USER=boss
DEPLOY_USER=deploy
ROOT_USER_SSH_DIR="/home/$ROOT_USER/.ssh"
DEPLOY_USER_SSH_DIR="/home/$DEPLOY_USER/.ssh"

apt-get update
apt-get -y -q install zlib1g-dev build-essential libssl-dev htop vim curl nginx mysql-server mysql-client-5.5 mysql-client-core-5.5 libdbd-mysql-perl libmysqlclient-dev mysql-server-core-5.5
apt-get -y -q install libncurses5-dev libedit-dev git-core libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties clang-3.6 clang++-3.6 llvm-3.6 libffi-dev
apt-get -y -q install openjdk-7-jre imagemagick
apt-get -y -q install libmagickcore-dev libmagickwand-dev libmagick-dev

add-apt-repository -y ppa:webupd8team/java
apt-get update
apt-get -y install oracle-java8-installer

echo "Java version:"
java -version

ln -s /usr/bin/clang-3.6 /usr/bin/clang
ln -s /usr/bin/clang++-3.6 /usr/bin/clang++
ln -s /usr/bin/llvm-config-3.6 /usr/bin/llvm-config

useradd -m -U -s /bin/bash $ROOT_USER
useradd -m -U -s /bin/bash $DEPLOY_USER

echo "Giving sudo privileges to the operating user $ROOT_USER..."
echo "$ROOT_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$ROOT_USER
chmod 0440 "/etc/sudoers.d/$ROOT_USER"

echo "Setting operating users' ssh authorized_keys..."

echo "boss user..."
mkdir -p $ROOT_USER_SSH_DIR
chown $ROOT_USER:$ROOT_USER $ROOT_USER_SSH_DIR

echo "$PUB_KEY" >$ROOT_USER_SSH_DIR/authorized_keys
chown $ROOT_USER:$ROOT_USER $ROOT_USER_SSH_DIR/authorized_keys
chmod 600 $ROOT_USER_SSH_DIR/authorized_keys

echo "deploy user..."
mkdir -p $DEPLOY_USER_SSH_DIR
chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_USER_SSH_DIR

echo "$PUB_KEY" >$DEPLOY_USER_SSH_DIR/authorized_keys
chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_USER_SSH_DIR/authorized_keys
chmod 600 $DEPLOY_USER_SSH_DIR/authorized_keys

echo "Creating deployment directory structure"
mkdir -p "/home/$DEPLOY_USER/web/shared/config"
chown $DEPLOY_USER:$DEPLOY_USER "/home/$DEPLOY_USER/web/"
chown $DEPLOY_USER:$DEPLOY_USER "/home/$DEPLOY_USER/web/shared"
chown $DEPLOY_USER:$DEPLOY_USER "/home/$DEPLOY_USER/web/shared/config"

echo "Setting up elasticsearch"
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.2.0.deb
dpkg -i elasticsearch-5.2.0.deb
update-rc.d elasticsearch defaults

echo "/home/deploy/web/current/log/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  copytruncate
}
" >>/etc/logrotate.conf

echo "Done. Please disable root ssh access and password authentication"

# Additional steps:
# edit /etc/ssh/sshd_config and disable PasswordAuthentidation & root login
# sudo service ssh restart
# create /home/deploy/web/shared/config/database.yml
# create /home/deploy/web/shared/config/secrets.yml (using `rake secret` to generate the actual secret)
# setup the config file for nginx (cap puma:nginx_config)
# copy and paste the elasticsearch.yml to /etc/elasticsearch
# setup mysql config /etc/mysql/my.cnf
# copy and paste the config/kernel/sysctl.conf file to /etc/sysctl.conf (create a backup first!)
# setup memcached?
# reboot the machine

