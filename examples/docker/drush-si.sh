#!/usr/bin/env bash
# initialize a drupal environment using drush
umask 000

# load basic functions and project environment
. functions

echo "*************************************************************************************"
echo This will install a site with default values
echo "*************************************************************************************"

if [ $(find "$(docroot)" -prune -empty) ]; then
    ./download_drupal.sh
fi

drush si -y \
    --db-url="mysql://${DB_DRUPAL_USER}:${DB_DRUPAL_PASSWORD}@$DB_DOMAIN/${DB_DRUPAL_DB}"  \
    --db-su=root \
    --db-su-pw=${DB_ROOT_PASSWORD} \
    --site-name=${SITE_NAME}  \
    --account-name=${ADMIN_USER} \
    --account-pass=${ADMIN_PASSWORD}

# download and enable some basic contrib modules
if [ "${DRUPAL_VERSION}" = "8" ]; then # Drupal 8

    drush dl -y \
        admin_toolbar \
        backup_migrate \
        components

    drush en -y \
        admin_toolbar \
        admin_toolbar_tools \
        backup_migrate \
        components \

else # Drupal 7
    drush dis -y \
        overlay \
        toolbar \

    drush dl -y \
        admin_menu \

    drush en -y \
        admin_menu \
        admin_menu_toolbar \

fi

# Open browser
./browse.sh "http://$WWW_DOMAIN/user/login?destination=/admin/reports/status"
