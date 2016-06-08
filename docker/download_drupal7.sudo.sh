#!/usr/bin/env bash
# initialize a drupal 7 environment using drush

. environment > /dev/null

cd ../www
docroot=$(pwd)/docroot
tmp=$(pwd)/tmp
echo "*************************************************************************************"
echo "*** This script must be run as sudo!"
echo "*************************************************************************************"
echo This will remove existing files from ${docroot} and download a new Drupal 7 instance.
echo "*************************************************************************************"
while true; do
    read -p "Do you want to continue? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "processing..."

docker run -i --rm -v "${tmp}":/app -v ${drushvol} --net=${net} my/drush -y dl drupal-7
rm -R "${docroot}"
mv ${tmp}/drupal-7* "${docroot}"

cd "${docroot}"

# make contrib folders as they will be updated by drush
contrib="modules/contrib themes/contrib libraries"
for i in ${contrib}; do
  mkdir sites/all/${i} 2> /dev/null
done

# make custom folders to be managed by you
custom="modules/custom modules/features themes/custom"
for i in ${custom}; do
  mkdir sites/all/${i} 2> /dev/null
  chown -R ${SUDO_UID}:${SUDO_GID} sites/all/${i}
done

# prepare settings.php
cp -p sites/default/default.settings.php sites/default/settings.php
echo "\$conf[\"file_private_path\"] = \"../private/default/files\";" >> sites/default/settings.php
echo "\$conf[\"file_temporary_path\"] = \"../tmp\";" >> sites/default/settings.php
old_umask=$(umask)
umask 000
mkdir sites/default/files
umask $old_umask