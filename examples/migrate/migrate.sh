#!/usr/bin/env bash
# steps to be taken during migration from Drupal 7 to Drupal 8
#
# include basic functions and environment for migration
. migrate-env

# @function drush_si
#           will do a site install with docker/drush-si.sh
# @usage    drush_si
function drush_si() {
    pushd "$(pwd)" > /dev/null
    cd docker
    ./drush-si.sh
    popd >/dev/null
}
# @function drush_migrate
#           calls dockerized drush for migrate* utilities. Adds database credentials to drush
# @usage    drush_migrate migrate_command_without_migrate_prefix
function drush_migrate() {
    drush "migrate-${@}" -y \
        --legacy-db-url=mysql://"${DB_DRUPAL_USER}":"${DB_DRUPAL_PASSWORD}"@$DB_DOMAIN/${DB_DRUPAL_DB}_d7 \
        --legacy-root="/app/$(app_legacy_root)"
}

# @function install_requirements
#           install requirements into Drupal 8
# @ usage   install_requirements
function install_requirements() {
    drush en -y migrate migrate_drupal migrate_upgrade migrate_tools migrate_plus
}
# @function backup_db
#           creates a backup of the Drupal 8 database
# @usage    backup_db
function backup_db() {
    drush sql-dump -y \
        --result-file=$(backup_file) \
        --structure-tables-key=common \
        --skip-tables-key=common
}
# @function configure
#           configure migration
# @usage    configure
function configure() {
    drush_migrate upgrade --configure-only
}

# @function create_module
#           create a new module for the migration
# @usage    create_module
function create_module() {
    rm -R "$(module_dir)" 2> /dev/null
    echo generating module $(module_name)...
    drupal generate:module \
        --module=$(module_name) \
        --machine-name=$(module_name) \
        --module-path=/$(app_module_basedir) \
        --core="8.x" \
        --package="Migration" \
        --description="A custom Drupal-to-Drupal migration" \
        --composer \
        --dependencies="migrate_drupal, migrate_plus"

     mkdir "$(module_dir)/config"
     mkdir "$(module_dir)/config/install"
}

# @function config_module
#           export site configuration and copy the relevant configuration to the custom module
# @usage    config_module
function config_module() {
    rm -R $(projectdir)/www/tmp/migrate 2> /dev/null
    drush config-export -y --destination=/app/tmp/migrate
    cp  www/tmp/migrate/migrate_plus.migration.* \
        www/tmp/migrate/migrate_plus.migration_group.migrate_*.yml \
        "$(module_dir)/config/install/"
}

# @function restore_db
#           restore the previously backed up database
# @usage    restore_db
function restore_db() {
    drush sql-drop -y
    echo "restoring database..."
    drush sql-query -y --file=$(backup_file)
}

# @function customize
#           customize the migration
# @usage    customize
function customize() {
    pushd "$(pwd)" > /dev/null
    ./migrate-customize.sh
    popd >/dev/null
}
# @function enable_module
#           enables the module created by create_module
# @usage    enable_module
function enable_module {
    drush en -y $(module_name)
}
# @function migrate_status
#           show the migration status
# @usage    migrate_status
function migrate_status() {
    drush -y migrate-status
}

# @function run_migration
#           run the migration process
# @usage    run_migration
function run_migration() {
  drush -y migrate-import --all
}

max_steps=10
for i in {0..10}; do
    result[${i}]=" "
done
while true; do
    echo "
******************************************************************
* Migrate a Drupal 7 installation into a Drupal 8 installation   *
******************************************************************
"
    if [ -z ${first_run} ]; then
        first_run=false
        echo "
You need a database backup of the Drupal 7 database in the database
${DB_DRUPAL_DB}_d7 and the files of Drupal 7 in $(legacy_root).
Also the custom and contributed modules necessary for your new
Drupal 8 site must be installed (except for the migation modules)."
        echo "
This script follows an installation manual on
https://drupalize.me/blog/201605/custom-drupal-drupal-migrations-migrate-tools
"
    fi
    echo "${result[0]} [ 0] Install a brand new site now (optional)"
    if [ "${result[0]}" == " " ]; then
        echo "       You can adapt docker/drush-si.sh to install and enable all"
        echo "       needed modules during a site install."
        echo
    fi
    echo "${result[1]} [ 1] Install necessary migration modules"
    echo "${result[2]} [ 2] Backup your Drupal 8 database"
    if [ "${result[3]}" == " " ] && [ "${result[2]}" != " " ]; then
        echo
        echo "       For the next step make sure you have copied the Drupal 7 data into"
        echo "       ${MYSQL_DRUPAL_DB}_d7 database and all relevant files into"
        echo "       $(projectdir)/www/docroot/sites/default/files!"
    fi
    echo "${result[3]} [ 3] Generate a migration configuration from Drupal 7 database and files"
    echo "${result[4]} [ 4] Create a custom module $(module_name) for the migration."
    echo "${result[5]} [ 5] Export the site's migration configuration into this module"
    echo "${result[6]} [ 6] Restore your Drupal 8 database"
    echo "${result[7]} [ 7] Customize your configuration (optional)"
    echo "${result[8]} [ 8] Enable your module $(module_name)"
    echo "${result[9]} [ 9] Show the migration status"
    echo "${result[10]} [10] Run the migration"
    echo "  [ x] exit"
    if [ ${next_inp} ]; then
        if [ ${next_inp} -gt ${max_steps} ]; then
            next_inp="x"
        fi
    else
        next_inp=0
    fi
    echo -n "Enter your selection (or simply hit enter for next step \"${next_inp}\") "
    read inp
    if [ -z "${inp}" ]; then
        inp=${next_inp}
        echo "${inp}"
    fi
    case "${inp}" in
        0)  drush_si;;
        1)  install_requirements;;
        2)  backup_db;;
        3)  configure;;
        4)  create_module;;
        5)  config_module;;
        6)  restore_db;;
        7)  customize;;
        8)  enable_module;;
        9)  migrate_status;;
        10) run_migration;;
        x|X) break;;
        *) continue;;
    esac
    result[${inp}]=">"
    next_inp=$((inp + 1))
done
