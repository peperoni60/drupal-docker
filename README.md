#  Drupal-Docker Development
## Why use Docker?
The first question you would ask would just be this: "Why in the hell should I use docker? I have a development machine running Apache and PHP and Mysql. And now Docker?". Yes you are right. All of these are available on development machines. Let me explain by an example why this could be a problem:
I was very curious to update my computer from Kubuntu 15.10 to the latest Kubuntu 16.04. And what did I get? I got PHP 7.0 and lost my PHP 5.6 installation. But my servers in the wild (aka Internet) are still running on PHP 5.6! So I decided to remove all the Apache, PHP and Mysql stuff from my machine and installed Docker.
With Docker you can create containers holding project specific data while they depend on common images. I investigated Docker and created a checklist and scripts to create Docker-based Drupal development environments. As I am on Linux, it was developed and tested on Linux. But I am sure it will run on Mac and Windows in a similar way.
By the hand: I also use PhpStorm for development so I describe it from this view. Im also sure you can adapt my explanations to other development tools, too.
## How to install Docker
You can find several tutorials on the web, especially on the Docker website, how to install Docker. I followed this (https://docs.docker.com/engine/installation/linux/ubuntulinux/) and was very happy with it. The advantage of a Linux-based system is, that it does not need docker-machine, boot2docker, virtualbox and so on ;)
As I wanted to use docker-compose, too, I tried to install it from the repositories, too. But I didn't get the right version (which allowed my to write version 2 compliant docker-compose.yml files). So what to do? The solution is so simple: Use Docker to run docker-compose. That means: Download a script that runs docker-compose in a docker container. You'll find the installation instructions here: https://docs.docker.com/compose/install/#install-as-a-container On Linux run the commands as sudo!

> To add a Docker server in PhpStorm on Linux, use unix:///var/run/docker.sock as API URL.

> Sometimes this kind of docker-compose has problems to run when using the PhpStorm built-in Docker tools. But that doesn't matter as I wrote scripts to run docker-compose. And these scripts integrate well with PhpStorm. See below

## Set up a drupal development project with Docker

This instructions can help you to set up a drupal development project with one project-specific container for Apache/PHP/drush/drupal-console and one project specific container for Mysql. Both containers run in a project-specific network. All the project files (PHP, other files, Mysql database files) will be stored locally (that means: on the host's file system) and not within the containers. Thus the containers could be deleted and recreated as needed without losing data. 

> The following instructions use _italic_ text as placeholders. These placeholders must be replaced by real values when following the instructions.

* Create a new empty project _Project_ in PhpStorm (File>New Project>Empty Project).

* unpack install.tar.gz into this _Project_.

* We will get this directory structure:
    * _Project_
        * _docker-to-be-renamed_
        * www
            * docroot
            * tmp
            * private
               
    * The name of **_Project_** can be chosen as you like.
    * **_docker-to-be-renamed_** is the folder for the Docker utilities and scripts. It provides the **context** for all created containers and networks within this project. **The name must be unique within the Docker host!** It's time now to change the name. (PhpStorm: mark _docker-to-be-renamed_ Shift+F6). For example you can create a name with the string "Docker" and a project shortcut.
    * **docroot** is the root folder for Apache. Here all PHP-files and user created files will reside. Don't change the name as the scripts rely on it.
    * **tmp** is a directory for temporary files. It can be used as tmp-directory in Drupal (../tmp)
    * **private** is a directory for holding the private files in Drupal (e.g. Backups) (../private)
    * Following these steps Docker will create additional directories **_Project_.log** and **_Project_.mysql** to hold Apache log files and the Mysql database files.
    
* If not already done **PhpStorm** will probably detect the presence of Docker files and offer to install the Docker plugin. Do so, please.

* Now it's time to make modifications to **environment.env**. This file holds environment variables to pass to docker during compose:     

    * **APACHE_NAME** is the name of the container to be created for Apache/PHP. The name could be composed of "apache" and a project shortcut. **The name has to be unique within the Docker host!** 
    * **APACHE_IMAGE** is the name of the folder containing the build file for the Apache container. These are currently: 
        * Ubuntu_15.10: Apache 2 with PHP 5.6
        * Ubuntu_16.04: Apache 2 with PHP 7.0
        These folders are in the same folder as environment.env.
    * **APACHE_HOSTNAME** is the domain name, which could be later added to /etc/hosts. You can then us this name to open your website in a browser. **The name has to be unique within the Docker host!**
    * **MYSQL_NAME** is the name of the container to be created for Mysql. The name could be composed of "mysql" and a project shortcut. **The name has to be unique within the Docker host!**
    * **MYSQL_IMAGE** is the name of the image to create the Mysql container of. As we do not make modifications to that image, we could directly use an image from the docker hub. Normally it is not necessary to modify this entry.
    * **MYSQL_HOSTNAME** is the host name of the Mysql container which could be later added to /etc/hosts. In PhpStorm you can then connect to the database using this name instead of using the IP address (remember: Mysql is not running on the local host and we do not redirect ports). 
        > During Drupal installation you can not use this name to connect to the database, as this name is known on the host machine only. Use the name "mysql" instead, see below.
    
    * **MYSQL_ROOT_PASSWORD** is the root password for Mysql. You may change it once.
    * **MYSQL_DRUPAL_USER** is the name of the user to connect to the drupal database. You should change this name once.
    * **MYSQL_DRUPAL_DB** is the name of the database to use in Drupal. You should also change this name once.
    * **MYSQL-DRUPAL_PASSWORD** is the password of the drupal user for this database. You should also change this password once.
    * **NET_SUBNET** is the subnet to run the containers of this project in. To separate the projects sufficiently, you should create a subnet for each project. The most simple method is to increase the 3rd octet for each project. If the private range 172.16/12 is occupied you must switch to another private range (see https://en.wikipedia.org/wiki/Private_network ).
    * **NET_GATEWAY** is the gateway of the subnet. The first IP-Address should work(i.e. only change the 3rd octet).
    * **APACHE_IP** is the IP address of the Apache container. Here it also should be sufficient to change the 3rd octet.
    * **MYSQL_IP** is the IP address of the Mysql container. Here it also should be sufficient to change the 3rd octet.

* Now you can create the containers and the network for this project. In PhpStorm start the script **startup.sh** (mark startup.sh, Ctrl+Shift+F10). On the very first run Docker will download the basic image and, in case of Apache, create a dependent image with all required applications. If the containers are running (you can control it in PhpStorm by clicking on the Docker-tab at the lower left border) you can take the next steps.
* To create the database for Drupal, run the script **init_mysql_drupal_db.sh** (mark init_mysql_drupal_db.sh, Ctrl+Shift+F10). **A database with same name will be dropped and recreated!**
* Now you have to download Drupal 7 or Drupal 8. To do so, run **download_drupal7.sh** or **download_drupal8.sh** (mark the script, Ctrl+Shift+F10). **All files and directories in www/docroot will be deleted!**
* Before we start to install our Drupal website we have to modify /etc/hosts to add the host names of our containers. To do so, open the terminal in PhpStorm (the tab on the bottom left side). Change into the directory with **addhost.sh**. `sudo addhost.sh` will do the job.
* Now we can open the website at “http://_APACHE_HOSTNAME_” (or “http://_APACHE_IP_” if we could not change /etc/hosts).

    > In Drupal the name of the mysql-hosts is not “localhost” but “mysql”, that is the name of the connected mysql-service.

## Debugging with PhpStorm
The Apache-container has been created with xdebug activated. So you can debug any web-session on this server in PhpStorm. To switch on/off debugging in the browser you will find a generator for bookmarklets to control php-debugging on this page https://www.jetbrains.com/phpstorm/marklets/ . Add these bookmarklets to your browser. To switch on/off debugging in PhpStorm you will find the icon “Start Listening for PHP Debug Connections” on the top right edge.

### Start a debugging session
* Set debug breakpoints in PhpStorm
* Switch on “Start Listening for PHP Debug Connections” in PhpStorm
* Start your Browser
* Switch on debugging in your Browser


