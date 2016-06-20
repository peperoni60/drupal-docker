#!/usr/bin/env bash
# initialize a drupal environment using drush
umask 000

# load basic functions and project environment
. functions

echo "*************************************************************************************"
echo This will install a site with default values
echo "*************************************************************************************"

if [ $(find "$(projectdir)/www/docroot" -prune -empty) ]; then
    echo "Do you want to download Drupal 7 or 8 or exit? (7/8/x) "
    while true; do
        read seveneight
        case $seveneight in
            [78]* ) break;;
            [xX]* ) exit;;
            * ) echo "Please answer 7 or 8.";;
        esac
    done

    cd "$(projectdir)/docker"
    ./download_drupal${seveneight}.sh
fi

db_url=
cd "$(projectdir)/www/docroot"
drush si \
    --db-url="mysql://${MYSQL_DRUPAL_USER}:${MYSQL_DRUPAL_PASSWORD}@mysql:3306/${MYSQL_DRUPAL_DB}"  \
    --db-su=root \
    --db-su-pw=${MYSQL_ROOT_PASSWORD} \
    --site-name=${SITE_NAME}  \
    --account-name=${ADMIN_USER} \
    --account-pass=${ADMIN_PASSWORD}

# download and enable some basic contrib modules
if [ -d core ]; then # Drupal 8

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
URL="http://$APACHE_HOSTNAME/user/login?destination=/admin/reports/status"
[[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
path=$(which xdg-open || which kde-open || which gnome-open) &&  $path "$URL" && exit
echo "Can't find browser"