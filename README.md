#  Drupal-Docker Development

- [Why use Docker?](#why)
- [What will you get afterwards?](#what)
- [PhpStorm prerequisites](#pre)
- [How to install Docker](#how)
- [Overview](#overview)
- [Set up a drupal development project with Docker](#setup2)
    - [Set up the environment](#setup3)
    - [Create and start the containers](#create)
    - [What are the host names and IP adresses?](#ip)
    - [Install Drupal website with default values](#default)
    - [Install Drupal with custom values](#custom)
- [Features of your new development environment](#features)
    - [Starting and stopping the environment in PhpStorm](#starting)
    - [Debugging with PhpStorm](#debugging)
    - [Using Drush, the Drupal console, or Composer in PhpStorm](#drush)
    - [Open a shell in the db or www container](#shell)
    - [Moving/sharing the development environment](#share)
- [Troubleshooting](#trouble)
- [Bonus](#bonus)
    - [SASS compilation](#sass)
    - [Node.js, npm and gulp](#node)
    - [Migration from Drupal 7 to Drupal 8](#migrate)

    


## Why use Docker? <a name="why"></a>
The first question you could ask would just be this: "Why in the hell should I use docker? I have a development machine running Apache and PHP and Mysql. And now Docker?". Yes you are right. All of these are available on development machines. Let me explain by an example why this could be a problem:

> I was very curious to update my computer from Kubuntu 15.10 to the latest Kubuntu 16.04. And what did I get? **I got PHP 7.0 and lost my PHP 5.6 installation**. But my servers in the wild (aka Internet) are still running on PHP 5.6! So I decided to remove all the Apache, PHP and Mysql stuff from my machine and installed Docker.  

With Docker you can create containers holding project specific data while they depend on common images. You can even copy whole development environments from one machine to another or only share the settings of a development environment with others. I investigated Docker and created a checklist and some scripts to create Docker-based Drupal development environments and to interact with Docker containers. As I am on Linux, it was developed and tested on Linux. But I am sure it will run on Mac and Windows in a similar way.  

I also use **PhpStorm** (https://www.jetbrains.com/phpstorm/) for development so I describe it from this point of view. Im also sure you can adapt my explanations to other development tools, too.

> ### **You don't need to install apache, php or mysql on the computer to run this development environment!** The only requirement is to install Docker (see below).

## What will you get afterwards? <a name="what"></a>

All you need to install is **Docker** and **PhpStorm**! You don't need to install a LAMP-Stack or something else. When you followed this installation instruction, you will get a functional development environment. In the latest version of this project I changed to use the image files from **Docker4Drupal** (http://docker4drupal.org). So you will get:
 
 * Docker.
 
 * PhpStorm.
 
 * A container with nginx.
 
 * A container with PHP 7.0 or 5.6, Drush, Drupal console, composer
 
 * A container with Mariadb
 
 * A container with mailhog, a webmail client that will receive all the mails you send in your Drupal development environment.
 
 * Node.js, npm and gulp on the fly (managed by Docker). You need gulp if you want to develop a Zen-theme based on current Zen.
 
 * SASS/SCSS compilation on the fly (managed by Docker).
 
 You can extend the list as you like. Use the provided scripts as templates.

## PhpStorm prerequisites <a name="pre"></a>

To work with PhpStorm efficiently, some Plugins must be installed: To install the Docker plugin go to File→Settings→Plugins and **activate the Docker plugin**. Here you can also **activate the Drupal support plugin** and the **BashSupport plugin**, if not already active. 

## How to install Docker <a name="how"></a>

You can find several tutorials on the web, especially on the Docker website, how to install Docker. I followed this (https://docs.docker.com/engine/installation/linux/ubuntulinux/) and was very happy with it. The advantage of a Linux-based system is, that it does not need docker-machine, boot2docker, virtualbox and so on ☺.  

As I wanted to use docker-compose, too, I tried to install it from the repositories. But I didn't get the right version, which allowed my to write version 2 compliant docker-compose.yml files. So what to do? The solution is so simple: Use Docker to run docker-compose. That means: Download a script that runs docker-compose in a docker container. You'll find the installation instructions here: https://docs.docker.com/compose/install/#install-as-a-container On Linux run the commands as sudo!

> To add a Docker server in PhpStorm on Linux, use **`unix:///var/run/docker.sock`** as API URL.

> Sometimes this kind of docker-compose has problems to run when using the PhpStorm built-in Docker tools. But that doesn't matter as I wrote scripts to run docker-compose. And these scripts integrate well with PhpStorm. See below.

## Overview <a name="overview"></a>

These are the minimal steps to take if you set up and work with a project:

1. Create a new project (**once** per project)

2. Setup the environment (**once** per project)

3. Create and start the containers (**once** per project)

4. Install Drupal and a drupal site (**once** per project)

5. Start/Stop the containers (regularly, as needed)

If you run into troubles check the chapter **Troubleshooting** below.


## Set up a drupal development project with Docker <a name="setup2"></a>

This instructions can help you to set up a drupal development project with one project-specific container for nginx, one for PHP, one project specific container for Mysql and one container for mailhog, to receive the mails you will send by drupal. All containers run in a project-specific network. All the project files (PHP, other files, Mysql database files) will be stored locally (that means: on the host's file system) and not within the containers. Thus the containers could be deleted and recreated as needed without losing data.

**So, let's go!**
 
> The following instructions use *italic* text as placeholders. These
> placeholders must be replaced by real values when following the instructions.

* Create a new empty project *Project* in PhpStorm (File→New Project→Empty Project).

* clone (or download) https://github.com/peperoni60/drupal-docker into this *Project*.

* We will get this directory structure:
    * *Project*
        * docker
        * examples
            * docker
            * migrate
            * phpstorm

* During setup, the directory structure will become something like this:
    * *Project*
        * docker
        * **docker runtime**
            * **console**
            * **drush**
            * **drush-backups**
            * **log**
            * **mysql**
            * **mysql-init**
        * examples
            * docker
            * migrate
            * phpstorm
        * **www**
            * **config**
            * **docroot**
            * **private**
            * **tmp**
            
* The name of ***Project*** can be chosen as you like.

* **docker** contains build files and utilities for Docker

* **docker-runtime** contains the runtime data (databases, configuration files and so on). 
 
* **examples** contains the example files used during setup.

* **www** and subsequent directories will be created automatically during installation

    * **config** is the folder to hold the Drupal configuration files (instead of sites/all/files/*some_config_dir*.
    
    * **docroot** is the root folder for Apache. Here all PHP-files and user created files will reside.
    
    * **tmp** is a directory for temporary files. It can be used as tmp-directory in Drupal (`admin/config/media/file-system`, use `../tmp`)
    
    * **private** is a directory for holding the private files in Drupal, but outside the web root (`admin/config/media/file-system`, use `../private`, in D8: settings.php). If you install backup_migrate, you will need it!

### Set up the environment<a name="setup3"> </a>

Now go into the "docker" folder and run **startup.sh** (mark `startup.sh`, then press Ctrl+Shift+F10). This will create the necessary directories. On the very first run, it will copy some files from the examples directory to the docker directory and terminate. Now edit the *Project*/docker/environment file.  

This file holds environment variables to pass to docker during compose and aliases to be used on the command line:     

> Necessary changes are annotated with TODOs in the environment file! 

* **PROJECT_NAME_PLAIN** is used to build the names of Images, Containers and Networks. You should supply a name that is unique within the your machine. It must consist of **lower case letters** and **numbers**, no hyphens, dots or underscores!

* **PROJECT_NAME** is the name of the project. Do not use whitespaces in the name! If you do a site-install with drush, this will become the site name.

* **SUBNET** is the private subnet of the network, the containers will run in. It must be unique within all your projects.

* **DRUPAL_VERSION** could be 7 or 8. It is used to specify some environment variables for the container and to create the directory structure.

* **PHP_VERSION** could be 7 or 5.6. It is used to select the right version of the php container image.

* **PHP_XDEBUG_ENABLED** decides, wether Xdebug is enabled or not.

You can leave the rest of the file as is.


### Create and start the containers <a name="create"></a>

Now you can create the containers and the network for this project. 

* In PhpStorm start the script **startup.sh** in the "docker" folder again (mark `startup.sh`, then press Ctrl+Shift+F10). When the containers are running (you can control it in PhpStorm by clicking on the Docker-tab at the lower left border) you can take the next steps.
> **Tip**  
In PhpStorm you can now easily add a run configuration with startup.sh. From the "Run" menu select "Edit Configurations", select the entry "startup.sh" and save it (click on the diskette-icon). If you then go to File→Settings→Tools→Startup Tasks you can add startup.sh to the list to start/stop the containers when you open/close the PhpStorm project. 

* Before we start to install our Drupal website we have to modify **/etc/hosts** to add the host names of our containers. Open a terminal in PhpStorm (the tab on the bottom left side) and enter
    ```
    cd docker
    sudo ./addhost.sudo.sh
    ```
    This will do the job.
    
### What are the host names and IP adresses? <a name="ip"></a>
 
If you execute startup.sh to start the containers, there will be a file called `.docker.env` in the *Project*/docker directory. Open that file and you will find the host names and IP adresses. Alternatively you can look into /etc/hosts.
    

### Install Drupal website with default values <a name="default"></a>


To install a Drupal website with default values execute the script **drush-si.sh** in PhpStorm (mark `drush-si.sh`, then press Ctrl+Shift+F10). This will download Drupal if necessary, create a database if necessary, install Drupal within this database and open the site in your browser. The default credentials (if not changed in the environment) are user "me" with password "me".

> **All files and directories in www/docroot will be deleted!**


> **Note**
    The current image woodby/php:5.6 does not support "drush si". If you need to use php 5.6, stop the containers, temporarily switch to php 7.0 in the environment file and start the containers again with `startup.sh`. After the site has been installed, you can stop the containers again, switch back to php 5.6, and restart the containers.
    
> **Tip**
    To manually open your new site point your browser at “http:\/\/www.*PROJECT_NAME_PLAIN*.local” (or “http://*subnet*.101” if you could not change /etc/hosts). PhpMyAdmin is reachable via “http:\/\/pma.*PROJECT_NAME_PLAIN*.local”, Mailhog via “http:\/\/mail.*PROJECT_NAME_PLAIN*.local” (or their IP addresses). **You must'nt specify a port number** as described in the documentation of Docker4Drupal (http://docker4drupal.org) 
     
### Install Drupal with custom values <a name="custom"></a>

To download Drupal, execute the script **download_drupal.sh** in PhpStorm (mark the script, then press Ctrl+Shift+F10). This will prepare the docroot with writable "custom" folders in the "modules" and the "themes" folder.
> **All files and directories in www/docroot will be deleted!**

* Now you can open the website at “http:\/\/www.*PROJECT_NAME*.local” (or “http://*subnet*.101” if you could not change /etc/hosts).

> **Remember**
    In Drupal the name of the mysql-host is not “localhost” but "db.*PROJECT_NAME*.local" or simply “**db**”, that is the name of the connected mysql-service.

## Features of your new development environment <a name="features"></a>
 
### Starting and stopping the environment in PhpStorm <a name="starting"></a>

To start the development environment for your project, run the **startup.sh** script as described above. This will create a container representing this environment. In the "Run" tab PhpStorm creates a tab for startup.sh. Here you can control the environment and even stop the containers.
 
### Debugging with PhpStorm <a name="debugging"></a>

The Apache-container has been created with xdebug activated. So you can debug any web-session on this server in PhpStorm. To switch on/off debugging in the browser you will find a generator for bookmarklets to control php-debugging on this page https://www.jetbrains.com/phpstorm/marklets/ . Add these bookmarklets to your browser. To switch on/off debugging in PhpStorm you will find the icon “Start Listening for PHP Debug Connections” on the top right edge.

#### Start a debugging session

* Set debug breakpoints in PhpStorm

* Switch on “Start Listening for PHP Debug Connections” in PhpStorm

* Start your Browser

* Switch on debugging in your Browser

### Using Drush, the Drupal console, or Composer in PhpStorm <a name="drush"></a>

To start drush, the drupal console, or Composer open a terminal in PhpStorm. From the *Project* directory source **load-env** (by issuing ". load-env" or "source load-env" in the command line (without the quotation marks). This will set up aliases for drush and drupal to work with the containers.

> **Tip**  
> You can automate the loading of the environment by adding the following lines to your `~/.profile`.
> Thus every time you open a terminal in PhpStorm in this project or drag a project subfolder into the terminal window, the environment is loaded and the aliases/functions are set.
```bash
# load development environment
pushd "$(pwd)" > /dev/null
while [ ! -e "./load-env" ] && [ "$(pwd)" != "/" ]; do
  cd ..
done
if [ -e "./load-env" ]; then
   . ./load-env
fi
popd > /dev/null
```

> **Tip**  
If you issue `drush init` and/or `drupal init` or `composer init` once for your project you will also add some nice features from drush or the drupal console to shell: the shell prompt will show your git status, you will have code completion and so on.

If you run into problems with Drush, the Drupal console, or Composer you can run the commands directly in the php container. To do so, open a terminal in PhpStorm. There enter `php` without anything else and press enter. You will get into the shell of the php container and run as user www-data (82). If you instead enter `phproot` you will enter the shell as the root user.

### Open a shell in the db or www container <a name="shell"></a>
You can directly issue commands in any container in PhpStorm. Use it if needed and there is no command to open a shell (remember: the php container can be reached by `php` or `phproot`).

* Select the "Docker" tab.

* Connect to Docker, if PhpStorm is not already connected (press the green arrow on the left side).

* Right-click on the container (they must be running, otherwise start the containers with **startup.sh** described above.

* Select "Exec" from the context menu.

* Select "create" and then enter "/bin/sh". Later "/bin/sh" will be available in the menu.

Now PhPStorm will open a new shell.

> **Hint**  
If more than one shell-tab is open for that container, PhpStorm has problems to activtate that tab. Select the most right tab titled "/bin/sh" **and then click into that tab** to activate it and set the focus on it. Otherwise it could be that you type into the most recent active editor window! 

### Moving/sharing the development environment <a name="share"></a>

To move (or share) the development environment to another computer, simply copy the project folder. If necessary make some adjustments to **PROJECT_NAME_PLAIN** and/or **subnet** in file **environment**. Make sure, Docker and PhpStorm is installed and then run the **build.sh** scripts to create the images, run **addhost.sudo.sh** as root (sudo) and then execute **startup.sh** in PhpStorm.

To **share the definitions** of the project only share the "docker" folder of your project. On the taget machine follow the steps described in chapter "Overview".

## Troubleshooting <a name="trouble"></a>

If something doesn't work as expected, check this list:

* Are the containers running? In PhpStorm click on the Docker tab (and connect to Docker if necessary). 
* Try to stop the containers (stop the **startup.sh** session) and delete the containers. Restart the **startup.sh** session. 
* If conflicts with the network occur, try to delete the network. In a terminal (inside or outside PhpStorm) enter `docker network ls` and then `docker network rm [something_like_PROJECT_NAME_PLAIN]-dev-net`. Then check the value of PROJECT_NAME_PLAIN in the environment file. It must consist of lower case letters and numbers only! If you changed the name, stop and delete the containers, too (see above). Restart **startup.sh** to recreate the network and the containers.
* Keep in mind that the containers were designed to never hold project specific data that could not be recreated by Docker. So it is always safe to delete containers!


## Bonus <a name="bonus"></a>

### SASS compilation <a name="sass"></a>

In the *Project*/examples/PhpStorm directory you will find a file called **watchers.xml**. In PhpStorm go to File→Settings→Tools→FileWatchers and then import **watchers.xml**. Activate one of the watchers (not both!). Now every sass and scss file will be compiled into a css file. Did you install Sass? No, you don't. Sass is provided by a Docker image! In the same way you can add Compass and many other tools to your environment.

### Node.js, npm and gulp <a name="node"></a>

**Node**, **npm** and **gulp** are accessible via functions/aliases. Simply call node, npm or gulp on the command line as usual!
> **Hint**  
In most cases you have to install additional requirements to use a node.js project (e.g. in a Zen-theme). Then simply execute `npm install` in a terminal window in PhpStorm (don't forget to change into your node.js-project folder). This will install all needed plugins and utilites into a directory named **node-modules** in your node.js project. `npm install gulp` will make gulp available on the command line. **You can't install gulp globally because there is no global context!** 

### Migration from Drupal 7 to Drupal 8 <a name="migrate"></a>

In the *Project*/examples/migrate directory you will find some migrate scripts, that will assist you in migrating content from Drupal 7 to Drupal 8. The scripts can be run again and again until they meet your requirements. Migration is an iterative process. :(

1. Copy the migrate folder into the *Project* directory (so you will get *Project*/migrate).

2. Modify *Project*/docker/drush-si.sh to load all the Drupal 8 modules you need.

3. If needed, modify *Project*/migrate/migrate-customize.sh. See the Documentation inside the file.

4. Run *Project*/migrate/migrate.sh and follow the steps. You can exit and restart the script at any time and as much as you like.