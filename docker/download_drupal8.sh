#!/usr/bin/env bash
# initialize a drupal 8 environment using drush
umask 000

# load basic functions and project environment
. functions

docroot="$(projectdir)/www/docroot"

if [ ! $(find "${docroot}" -prune -empty) ]; then
    echo "*************************************************************************************"
    echo This will remove existing files from ${docroot} and download a new Drupal 8 instance.
    echo "*************************************************************************************"
    echo "Do you want to continue? (y/n) "
    while true; do
        read yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi
echo "processing..."

# download Drupal into a temporary location
cd "$(projectdir)/www/tmp"
rm -R drupal-8* 2> /dev/null
drush -y dl drupal-8

# rename the old location and try to remove it
if [ -d "${docroot}" ]; then
    mv "${docroot}" "${docroot}.rm"
    rm -R "${docroot}.rm"
    if [ -d "{docroot}.rm" ]; then
      echo "The old docroot could not be removed completely. Remove \"${docroot}.rm\" manually"
    fi
fi
mv drupal-8* ../docroot

cd "${docroot}"

# make some folders
folders="sites/default/files modules/contrib themes/contrib libraries modules/custom modules/features themes/custom"
for i in ${folders}; do
  mkdir ${i} 2> /dev/null
done

# prepare settings.php
cp -p sites/default/default.settings.php sites/default/settings.php
echo "\$settings[\"file_private_path\"] = \"../private/default/files\";" >> sites/default/settings.php
echo "\$settings[\"file_temporary_path\"] = \"../tmp\";" >> sites/default/settings.php
echo "\$config_directories[\"sync\"] = \"../config/default/sync\";" >> sites/default/settings.php
