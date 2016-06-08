#!/usr/bin/env bash
# initialize a drupal 8 environment using drush
. environment > /dev/null

CONTAINER=$MYSQL_NAME
REMOTEDIR=/var/tmp
TMPDIR=../www/tmp
INITFILE=adduserdb.sh
mkdir $TMPDIR 2> /dev/null
cat > $TMPDIR/$INITFILE << EOF
#!/usr/bin/env bash
BASEDIR=/var/tmp
cd \$BASEDIR
echo "*************************************************************************************"
echo This will remove existing database $MYSQL_DRUPAL_DB and create a new one.
echo "Do you want to continue? (y/n)."
echo "*************************************************************************************"
while true; do
    read yn
    case \$yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "processing..."
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" << EOF2 2> /dev/null
DROP DATABASE IF EXISTS $MYSQL_DRUPAL_DB;
CREATE DATABASE $MYSQL_DRUPAL_DB CHARACTER SET utf8;
GRANT ALL
  ON $MYSQL_DRUPAL_DB.*
  TO '$MYSQL_DRUPAL_USER'@'%'
  IDENTIFIED BY '$MYSQL_DRUPAL_PASSWORD'
  WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF2
EOF

chmod +x $TMPDIR/$INITFILE

docker exec -i $CONTAINER "$REMOTEDIR/$INITFILE"

rm $TMPDIR/$INITFILE


