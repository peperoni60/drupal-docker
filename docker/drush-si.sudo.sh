#!/usr/bin/env bash
# initialize a drupal 8 environment using drush

. environment > /dev/null

cd ../www
www=$(pwd)
docroot=$(pwd)/docroot
tmp=$(pwd)/tmp
echo "*************************************************************************************"
echo "*** This script must be run as sudo!"
echo "*************************************************************************************"
echo This will install a site with default values
echo "*************************************************************************************"

cd ${tmp}

db_url=mysql://${MYSQL_DRUPAL_USER}:${MYSQL_DRUPAL_PASSWORD}@mysql:3306/${MYSQL_DRUPAL_DB}

docker run -i --rm -v ${docroot}:/app -v ${drushvol} --net=${net} my/drush si --db-url=${db_url}  --db-su=root --db-su-pw=${MYSQL_ROOT_PASSWORD}

# adjust file permissions
sudo chmod -R a+rw ${docroot}/sites/default/files