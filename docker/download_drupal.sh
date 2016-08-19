#!/usr/bin/env bash
# initialize a drupal environment using drush
umask 000

# load basic functions and project environment
. functions

if [ ! $(find "$(docroot)" -prune -empty) ]; then
    echo "*************************************************************************************"
    echo This will remove existing files from $(docroot) and download a new Drupal ${DRUPAL_VERSION} instance.
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
rm -R drupal-${DRUPAL_VERSION}* 2> /dev/null
drush -y dl drupal-${DRUPAL_VERSION}

# rename the old location and try to remove it
if [ -d "$(docroot)" ]; then
    mv "$(docroot)" "$(docroot).rm"
    rm -R "$(docroot).rm"
    if [ -d "(docroot).rm" ]; then
      echo "The old docroot could not be removed completely. Remove \"$(docroot).rm\" manually"
    fi
fi
mv drupal-${DRUPAL_VERSION}* ../docroot

cd "$(docroot)"

# make some folders
if [ "${DRUPAL_VERSION}" = "7" ]; then
    folders="sites/default/files sites/all/modules/contrib sites/all/themes/contrib sites/all/libraries sites/all/modules/custom sites/all/modules/features sites/all/themes/custom"
else
    folders="sites/default/files modules/contrib themes/contrib libraries modules/custom modules/features themes/custom"
fi
for i in ${folders}; do
  mkdir ${i} 2> /dev/null
done

# prepare settings.php
# first rename default.settings.php to keep ownership, then copy back to old name
mv sites/default/default.settings.php sites/default/settings.php
cp -p sites/default/settings.php sites/default/default.settings.php
echo "\$conf[\"file_private_path\"] = \"../private/default/files\";" >> sites/default/settings.php
echo "\$conf[\"file_temporary_path\"] = \"../tmp\";" >> sites/default/settings.php
if [ "${DRUPAL_VERSION}" = "8" ]; then
    echo "\$config_directories[\"sync\"] = \"../config/default/sync\";" >> sites/default/settings.php
fi

