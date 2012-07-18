#!/bin/sh

SHA_PACK="31f418424db074f2f29140ceb61f314e7e1dd36b"

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install iptables patch

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Download Nginx"

wget https://github.com/exos/Gandalf/tarball/v0.2.1-beta -O gandalf-0.2.1-beta.tar.gz

if [ $? -ne 0 ]; then
  echo "Error downloading Nginx"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum gandalf-0.2.1-beta.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf gandalf-0.2.1-beta.tar.gz

if [ $? -ne 0 ]; then
  echo "Error uncompressing Nginx"
  exit 4
fi

cd exos-Gandalf-e893e98

echo "Installing"

echo "6c6
< IPTABLES_BIN=/usr/sbin/iptables
---
> IPTABLES_BIN=/sbin/iptables" | patch  etc/gandalf/gandalf.conf

mv etc/gandalf /etc/
mv rc-file/gandalf /etc/init.d/ 

if [ $? -ne 0 ]; then
  echo "Error installing"
  exit 7
fi

echo "Creating folders and permisits"
chmod +x /etc/init.d/gandalf

echo "Adding Nginx as services"
update-rc.d gandalf defaults

echo "Instalation is ok"
echo "########";
echo "WARNING: Don't init gandalf before configure it. Remember you have the command /etc/init.d/gandalf test for test"