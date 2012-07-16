#!/bin/sh

SHA_PACK="ede0e29b06cd2fd9646088f208259738fb36550e"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install apache2 php5 mysql-server php5-mysql php5-mcrypt php5-gd


if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Download osTicket"

wget http://osticket.com/dl/osticket_1.6.0.tar.gz

if [ $? -ne 0 ]; then
  echo "Error downloading osTicket"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum osticket_1.6.0.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf osticket_1.6.0.tar.gz

if [ $? -ne 0 ]; then
  echo "Error uncompressing osTicket"
  exit 4
fi

cd osticket_1.6.0

echo "Preparing"

mkdir /var/www/osticket


echo "Installing"

mv upload  /var/www/osticket/webdir
mv scripts  /var/www/osticket/
chown -R root:root /var/www/osticket
chmod -R 665 /var/www/osticket

mv /var/www/osticket/webdir/include/ost-config.sample.php /var/www/osticket/webdir/include/ost-config.php
chmod a+w /var/www/osticket/webdir/include/ost-config.php

echo "Alias /osticket /var/www/osticket/webdir

<Directory /var/www/osticket/webdir>
        Options FollowSymLinks

        DirectoryIndex index.php

        AllowOverride All
        Order Allow,Deny
        Allow From All

</Directory>
" > /etc/apache2/conf.d/osticket.conf

echo "Reload apache config"

/etc/init.d/apache2 force-reload

echo "Instalation is not complete, you have to continue by web, open in a browser: http://www.yourdomain.com/osticket/setup/ and follow the steps, you need too create a MySQL users for install the webapp."