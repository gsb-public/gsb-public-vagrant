#!/usr/bin/env bash

# NEVER ADD THIS INSIDE THE BOX FILE. THE BOX WILL FAIL TO LOAD.
if [ ! -f /home/vagrant/.ssh/id_rsa ];
then
  echo '
==================================
Add Symlinks for ssh
==================================';
  ln -s /vagrant/id_rsa /home/vagrant/.ssh/id_rsa
fi

echo '
==================================
Prepare html directory
==================================';
echo "Remove Files"
rm -Rf /var/www/htmlvag

echo "Pull acquia repo"
if [ ! -d /vagrant/gsbpublic ];
then
  su - vagrant -c 'cd /vagrant && git clone gsbpublic@svn-3224.prod.hosting.acquia.com:gsbpublic.git'
else
  su - vagrant -c 'cd /vagrant/gsbpublic && git pull'
fi

echo "Copy repository to /var/www/html"
cp -R /vagrant/gsbpublic/docroot/. /var/www/html

echo "Rebuild settings file"
rm -f /var/www/html/sites/default/settings.php
cp /home/vagrant/settings.php /var/www/html/sites/default/settings.php

echo "Rebuild files directory"
mkdir /var/www/html/sites/default/files
mkdir /var/www/html/sites/default/files/private
mkdir /var/www/html/sites/default/files/styles
echo 'SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006
Deny from all
Options None
Options +FollowSymLinks' > /var/www/html/sites/default/files/private/.htaccess;
chmod -R 777 /var/www/html/sites/default/files

echo '
==================================
Prepare Database
==================================';
su - vagrant -c 'drush sql-sync -y @gsbpublic.test @gsbpublic.local --create-db --structure-tables-list="cache,cache_*,history,search_*,sessions,watchdog" --no-cache'


cd /var/www/html

echo '
==================================
Disable Memcache, Acquia, Shield and Syslog
==================================';
drush dis -y memcache_admin acquia_purge acquia_agent shield syslog

echo '
==================================
Set site variables
==================================';
# Change admin password
drush upwd --password=admin admin

echo '
==================================
Enable dblog, Stage File Proxy, and Devel
==================================';
drush en -y dblog stage_file_proxy

echo '
==================================
Enable Views development
==================================';
drush vd -y

echo '
==================================
Clear the Drupal Cache
==================================';
drush cc all
drush status

echo '
==================================
Add Tests
==================================';
su - vagrant -c 'cd /home/vagrant/gsb-public-behat && git pull'
cp -R /home/vagrant/gsb-public-behat /var/www/html/profiles/gsb_public/gsb-public-behat

if [ ! -d /vagrant/gsb-public-behat-tests ];
then
  su - vagrant -c 'cd /vagrant && git clone git@github.com:gsb-public/gsb-public-behat-tests.git'
fi

ln -s /vagrant/gsb-public-behat-tests /var/www/html/profiles/gsb_public/gsb-public-behat/features/gsb-public-behat-tests

echo '
==================================
Restart Apache
==================================';
sudo service apache2 restart

echo '
==================================
Start Selenium Server
==================================';
DISPLAY=:1 xvfb-run java -jar /home/vagrant/gsb-public-behat/third-party/selenium-server-standalone.jar &> ./selenium-output.log &
