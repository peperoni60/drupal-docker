#  Drupal-Docker Development


## Why use Docker?
The first question you could ask would just be this: "Why in the hell should I use docker? I have a development machine running Apache and PHP and Mysql. And now Docker?". Yes you are right. All of these are available on development machines. Let me explain by an example why this could be a problem:

> I was very curious to update my computer from Kubuntu 15.10 to the latest Kubuntu 16.04. And what did I get? **I got PHP 7.0 and lost my PHP 5.6 installation**. But my servers in the wild (aka Internet) are still running on PHP 5.6! So I decided to remove all the Apache, PHP and Mysql stuff from my machine and installed Docker.  

With Docker you can create containers holding project specific data while they depend on common images. You can even copy whole development environments from one machine to another or only share the settings of a development environment with others. I investigated Docker and created a checklist and some scripts to create Docker-based Drupal development environments and to interact with Docker containers. As I am on Linux, it was developed and tested on Linux. But I am sure it will run on Mac and Windows in a similar way.  

By the hand: I also use **PhpStorm** (https://www.jetbrains.com/phpstorm/) for development so I describe it from this point of view. Im also sure you can adapt my explanations to other development tools, too.

## PhpStorm prerequisites

To work with PhpStorm efficiently, some Plugins must be installed: To install the Docker plugin go to File→Settings→Plugins and **activate the Docker plugin**. Here you can also **activate the Drupal support plugin** and the **BashSupport plugin**, if not already active. 

## How to install Docker

You can find several tutorials on the web, especially on the Docker website, how to install Docker. I followed this (https://docs.docker.com/engine/installation/linux/ubuntulinux/) and was very happy with it. The advantage of a Linux-based system is, that it does not need docker-machine, boot2docker, virtualbox and so on ☺.  

As I wanted to use docker-compose, too, I tried to install it from the repositories. But I didn't get the right version, which allowed my to write version 2 compliant docker-compose.yml files. So what to do? The solution is so simple: Use Docker to run docker-compose. That means: Download a script that runs docker-compose in a docker container. You'll find the installation instructions here: https://docs.docker.com/compose/install/#install-as-a-container On Linux run the commands as sudo!

> To add a Docker server in PhpStorm on Linux, use **`unix:///var/run/docker.sock`** as API URL.

> Sometimes this kind of docker-compose has problems to run when using the PhpStorm built-in Docker tools. But that doesn't matter as I wrote scripts to run docker-compose. And these scripts integrate well with PhpStorm. See below.

## Overview

These are the minimal steps to take if you set up and work with a project:

* Create a new project (**once** per project)

* Build Images (**once per computer**)

* Setup the environment (**once** per project)

* Create and start the containers (**once** per project)

* Install Drupal and a drupal site (**once** per project)

* Start/Stop the containers (regularly, as needed)


## Set up a drupal development project with Docker

This instructions can help you to set up a drupal development project with one project-specific container for Apache/PHP, one project specific container for Mysql. Both containers run in a project-specific network. All the project files (PHP, other files, Mysql database files) will be stored locally (that means: on the host's file system) and not within the containers. Thus the containers could be deleted and recreated as needed without losing data.

To use drush and drupal console you will set up separate images and these images are used by docker to create containers on the fly when needed. 
> The reason why you set up your own images is: you need to volume the drush and drupal console settings (.drush, .console) and, as they run as root inside, change the default umode 022 (read, write by owner, read only by others) to 000 (read/write to all). Thus the user www-data in the apache container is able to write into directories that are created by the root user of the drupal container. This is not a security issue, as we work locally and use private networks only. 

**So, let's go!**
 
> The following instructions use *italic* text as placeholders. These
> placeholders must be replaced by real values when following the instructions.

* Create a new empty project *Project* in PhpStorm (File→New Project→Empty Project).

* clone (or download) https://github.com/peperoni60/drupal-docker into this *Project*.

* We will get this directory structure:
    * *Project*
        * docker
            * drupalconsole
            * drush
            * Ubuntu_15.10
            * Ubuntu_16.04
        * www
            * docroot
            * tmp
            * private
               
    * The name of ***Project*** can be chosen as you like.
    
    * **docker** contains build files and utilities for Docker
    
    * **docroot** is the root folder for Apache. Here all PHP-files and user created files will reside. Don't change the name as the scripts rely on it.
    
    * **tmp** is a directory for temporary files. It can be used as tmp-directory in Drupal (`admin/config/media/file-system`, use `../tmp`)
    
    * **private** is a directory for holding the private files in Drupal, but outside the web root (`admin/config/media/file-system`, use `../private`, in D8: settings.php). If you install backup_migrate, you will need it!
    
    * Following the subsequent steps Docker will create additional directories ***Project*/.log** and ***Project*/.mysql** to hold Apache log files and the Mysql database files, ***Project*/.console** to hold the settings for the Drupal console, ***Project*/.drush** to hold the settings for Drush.

### Build the images

If this is your first project at all, you should build the images we need.
In PhpStorm run the scripts **build.sh** in docker/drupalconsole, docker/drush, docker/Ubuntu_15.10, docker/Ubuntu_16.04 (mark `build.sh`, then press Ctrl+Shift+F10). **These Images will be used in this project and reused in later projects**.

### Set up the environment

Now go into the "docker" folder and copy **sample.environment** to **environment**. This file holds environment variables to pass to docker during compose and aliases to be used on the command line:     

> Necessary changes are annotated with TODOs in the environment file! 

* **PROJECT_NAME** is used to build the names of Images, Containers and Networks. You should supply a name that is unique within the your machine. It must consist of lower case letters and underscores.

* **APACHE_NAME** is the name of the container to be created for Apache/PHP.

* **APACHE_IMAGE** is the name of the image for the Apache container (we will build the image later). These are currently (built in "Build the images"):

    * my/ubuntu:15.10: Apache 2 with PHP 5.6
    
    * my/ubuntu:16.04: Apache 2 with PHP 7.0
    
* **APACHE_HOSTNAME** is the domain name, which could be later added to /etc/hosts. You can then us this name to open your website in a browser. **The name has to be unique within the Docker host!**

* **MYSQL_NAME** is the name of the container to be created for Mysql.

* **MYSQL_IMAGE** is the name of the image to create the Mysql container of. Normally it is not necessary to modify this entry.

* **MYSQL_HOSTNAME** is the host name of the Mysql container which could be later added to /etc/hosts. In PhpStorm you can then connect to the database using this name instead of using the IP address (remember: Mysql is not running on the local host and we do not redirect ports). 

    > During Drupal installation you can not use this name to connect to the database, as this name is known on the host machine only. Use the name "mysql" instead, see below.

* **MYSQL_ROOT_PASSWORD** is the root password for Mysql. You may change it once.

* **MYSQL_DRUPAL_USER** is the name of the user to connect to the drupal database. You should change this name once.

* **MYSQL_DRUPAL_DB** is the name of the database to use in Drupal. You should also change this name once.

* **MYSQL-DRUPAL_PASSWORD** is the password of the drupal user for this database. You should also change this password once.

* **subnet** is a private subnet prefix. You should only change the last octet. **The subnet must be unique on the host machine**
* **NET_SUBNET** is the subnet to run the containers of this project in. (see https://en.wikipedia.org/wiki/Private_network ).

* **NET_GATEWAY** is the gateway of the subnet.

* **APACHE_IP** is the IP address of the Apache container.

* **MYSQL_IP** is the IP address of the Mysql container.

### Create and start the containers

Now you can create the containers and the network for this project. 

* In PhpStorm start the script **startup.sh** in the "docker" folder (mark `startup.sh`, then press Ctrl+Shift+F10). When the containers are running (you can control it in PhpStorm by clicking on the Docker-tab at the lower left border) you can take the next steps.
> **Tip**  
In PhpStorm you can now easily add a run configuration with startup.sh. From the "Run" menu select "Edit Configurations", select the entry "startup.sh" and save it (click on the diskette-icon). 

* Before we start to install our Drupal website we have to modify **/etc/hosts** to add the host names of our containers. Open a terminal in PhpStorm (the tab on the bottom left side) and enter
    ```
    cd docker
    sudo ./addhost.sudo.sh
    ```
    This will do the job.

* To download Drupal 7 or Drupal 8, open a terminal in PhpStorm and enter
    ```
    cd docker
    sudo ./download_drupal7.sudo.sh
    ```
    or
    ```
    cd docker
    sudo ./download_drupal8.sudo.sh
    ```
  This will prepare the docroot with writable "custom" folders in the "modules" and the "themes" folder.
    > **All files and directories in www/docroot will be deleted!**

* To install a Drupal website with default values, open a terminal in PhPStorm and enter
    ```
    cd docker
    sudo ./drush-si.sudo.sh
    ```
    This will create a database and install Drupal within this database.
    
* If you want to install Drupal via the browser you have to create the database for Drupal yourself by running the script **create_mysql_drupal_db.sh** in PhpStorm (mark `create_mysql_drupal_db.sh`, then press Ctrl+Shift+F10). **A database with same name will be dropped and recreated!**
    > **Tip**
    > To interact with the terminal window you have to click into it until you see a blinking cursor!

* Now we can open the website at “http://*APACHE_HOSTNAME*” (or “http://*APACHE_IP*” if we could not change /etc/hosts).

    > In Drupal the name of the mysql-hosts is not “localhost” nor *APACHE_HOSTNAME*, but “mysql”, that is the name of the connected mysql-service.

## Starting and stopping the environment in PhpStorm

To start the development environment for your project, run the **startup.sh** script as described above. This will create a container representing this environment. In the "Run" tab PhpStorm creates a tab for startup.sh. Here you can control the environment and even stop the containers.
 
## Rebuilding the containers in PhpStorm

In case you changed some definitions for the containers in the Dockerfiles or in docker-compose.yml you have to rebuild the images and/or the containers. Run the script **rebuild.sh** in PhpStorm as described above. After that, you can close the tab "rebuild.sh" in the "Run" tab.

## Debugging with PhpStorm

The Apache-container has been created with xdebug activated. So you can debug any web-session on this server in PhpStorm. To switch on/off debugging in the browser you will find a generator for bookmarklets to control php-debugging on this page https://www.jetbrains.com/phpstorm/marklets/ . Add these bookmarklets to your browser. To switch on/off debugging in PhpStorm you will find the icon “Start Listening for PHP Debug Connections” on the top right edge.

### Start a debugging session

* Set debug breakpoints in PhpStorm

* Switch on “Start Listening for PHP Debug Connections” in PhpStorm

* Start your Browser

* Switch on debugging in your Browser

## Using Drush or the Drupal console in PhpStorm

To start drush or the drupal console open a terminal in PhpStorm. From the *Project* directory source **load-env** (by issuing ". load-env" or "source load-env" in the command line (without the quotation marks). This will set up aliases for drush and drupal to work with the containers.

> **Tip**  
> You can automate the loading of the environment by adding the following lines to your `~/.profile`.
> Thus every time you open a terminal in PhpStorm in this project, the environment is loaded and the aliases are set.
```bash
# load development environment
if [ -e "./load-env" ]; then
   . ./load-env
fi
```

> **Tip**
If you issue `drush init` and/or `drupal init` once for your project you will also add some nice features from drush or the drupal console to shell: the shell prompt will show your git status, you will have code completion and so on.

## Open a shell in the mysql or apache container
You can directly issue commands in the apache or mysql containerin PhpStorm

* Select the "Docker" tab.

* Connect to Docker, if PhpStorm is not already connected (press the green arrow on the left side).

* Right-click on the apache or mysql-container (they must be green, otherwise start the containers with **startup.sh** described above

* Select "Exec" from the context menu.

* Select "create" and then enter "/bin/bash". Later "/bin/bash" will be available in the menu.

Now PhPStorm will open a new shell.
> **Hint**  
If more than one shell-tab is open for that container, PhpStorm has problems to activtate that tab. Select the most right tab titled "/bin/bash" **and then click into that tab** to activate it and set the focus on it. Otherwise it could be that you type into the most recent active editor window! 

## Moving/sharing the development environment

To move (or share) the development environment to another computer, simply copy the project folder. If necessary make some adjustments to **PROJECT_NAME** and/or **subnet** in file **environment**. Make sure, Docker and PhpStorm is installed and then run the **build.sh** scripts to create the images, run **addhost.sh** as root (sudo) and then execute **startup.sh** in PhpStorm.

# Bonus

## SASS compilation

In the docker directory you will find a file **watchers.xml**. In PhpStorm go to File→Settings→Tools→FileWatchers and then import **watchers.xml**. Activate one of the watchers (not both!). Now every sass and scss file will be compiled into a css file. Did you install Sass? No, you don't. Sass is provided by a Docker image! In the same way you can add Compass and many other tools to your environment.

> ### **You don't need to install apache, php or mysql on the computer to run this development environment!**
