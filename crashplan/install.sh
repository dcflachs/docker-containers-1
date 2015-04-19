#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# create ubuntu user
useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
echo "ubuntu:PASSWD" | chpasswd && \

# set user ubuntu to same uid and guid as nobody:users in unraid
usermod -u 99 ubuntu && \
usermod -g 100 ubuntu && \

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository ppa:webupd8team/java

# Accept JAVA license
echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

# Install Dependencies
apt-add-repository ppa:ubuntu-mate-dev/ppa
apt-add-repository ppa:ubuntu-mate-dev/trusty-mate
apt-get update -qq
apt-get install -qy grep sed cpio gzip wget oracle-java7-installer
apt-get install -y --force-yes --no-install-recommends xdg-utils python wget supervisor sudo nano net-tools mate-desktop-environment-core x11vnc xvfb gtk2-engines-murrine ttf-ubuntu-font-family
apt-get install -y xrdp

#########################################
##             INSTALLATION            ##
#########################################

# Install Crashplan
chmod +x /opt/crashplan-install.sh
/opt/crashplan-install.sh
mkdir -p /var/lib/crashplan
chown -R nobody /usr/local/crashplan /var/lib/crashplan


# swap in modified xrdp.ini
mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.original && \
mv /root/xrdp.ini /etc/xrdp/xrdp.ini && \
chown root:root /etc/xrdp/xrdp.ini && \


if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

mkdir -p /home/ubuntu/unraid

if [ -d "/home/ubuntu/unraid/wallpapers" ]; then
echo "using existing wallpapers etc..."
else
mkdir -p /home/ubuntu/unraid/wallpapers
cp /root/wallpapers/* /home/ubuntu/unraid/wallpapers/
fi


mkdir  /var/run/sshd
mkdir  /root/.vnc
/usr/bin/supervisord -c /root/supervisord.conf
while [ 1 ]; do
/bin/bash
done

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*

