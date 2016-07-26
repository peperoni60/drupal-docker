#  Drupal-Docker Development on a Mac

It is simple to run with the *Docker for Mac* native Docker Server (at least Version 1.12.0-rc4-beta20 as I write). I do not describe development with `docker-machine` which  would then  require *VirtualBox*.  

Notes for Mac:    

*  Mac  **PHPStorm** users 1) select a shell script and 2) click `⌃⇧R`  to run it (Shift+control+R and not `⌃⇧R`).
-  *Docker for Mac* does not require *VirtualBox*, it is implemented natively with *macOS HyperKit*.
-  `docker-machine` would require *VirtualBox*.

This *README* goes into some detail regarding the use of **PhpStorm** (https://www.jetbrains.com/phpstorm/) for development so I describe it from this point of view, but this repo wraps up a  lot of very useful that can be used simply from the command line.

So: you definitely don't need  *VirtualBox*; *Apache*; *php*; or *MySQL* installed on your Mac to run this development environment. The only *requirement* is to have *Docker for Mac* and  `homebrew` installed. 

## What will you get afterwards?

After you've followed this *README*, you will have a functional development environment with:
 
* *Docker*.
 
* *PhpStorm*.
 
* *Apache2* with *PHP 5.6* / *Mysql*, and/or *Apache2* with *PHP 7.0* / *Mysql* (in a *Docker* container). It will also contain a faked `sendmail` script so you can test sending mails out of your *Drupal* site.
 
* *Drush* (in a separate *Docker* container, thus independent of the PHP-version in the *Apache* container).
 
* *Drupal console* (in a separate *Docker* container) to be used in conjunction with *Drupal 8*.
 
*  *Node.js*, *npm* and *gulp* on the fly (managed by *Docker*) should you need `gulp` to compile your *SASS* etc.
 
* *SASS/SCSS* compilation on the fly (managed by *Docker* and *PHPStorm*).
 
The provided scripts can be used as templates for further tasks as you wish.

## PhpStorm prerequisites

To integrate nicely with *PhpStorm*, some Plugins must be installed: To
install the *Docker Integration* plugin go to
*PHPStorm→Preferences→Plugins→Install JetBrains Plugins* and choose and
activate the Docker plugin. Here you can also activate the *Drupal*
support plugin and the *BashSupport* plugin, if not already active.

## How to install Docker

This fork is adapted (with only *very* few minor changes to `peperoni60`'s base) to work with *Docker for Mac*. So, if you're doing your development and running *PHPStorm* on Linux you'll find really good Linux details in [his original repo](https://github.com/peperoni60/drupal-docker). But for the fork you're now reading, go to the [Docker for Mac](https://docs.docker.com/docker-for-mac/) page.

### To add a Docker server in PhpStorm on your Mac

-  Install the JetBrains Docker Integration plugin (as above)
-  `brew install coreutils socat`  
    We use `socat` as [a work around](https://forums.docker.com/t/worked-around-docker-http-s-api-no-longer-available-in-beta9/10474) to listen on the Unix socket for interprocess communicarion between *PHPStorm*
 and *Docker*.    We use `coreultils` to use the *Gnu* `env` command rather than the *Darwin* `env`: they're quite different.  
-  `socat TCP-LISTEN:2376,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock` in a _Terminal_ window and leave it running.
    
-  Go to  *PHPStorm→Preferences→Build Execution Deployment→Docker* and click **+** to define a _Docker Server_.
    -  Name the server
    -  Specify `unix:/http://localhost:2376` as  the _API URL_.
    -  Specify `/Users/<my Mac user>/.docker/machine/certs` as the
       _Certificates folder_ 
    -  Leave the default value `docker-compose` as is


## Overview

These are the minimal steps to take if you set up and work with a project:

1. Build Images (once **per Mac**)

2. Create a new project (once **per project**)

3. Setup the environment (once **per project**)

4. Create and start the containers (once **per project**)

5. Install Drupal and a drupal site (once **per project**)

6. Start/Stop the containers (regularly, as needed)


## Set up a drupal development project with Docker

This instructions guide you through setting up a _Drupal_ development project with one project-specific container for Apache/PHP, one project specific container for Mysql. Both containers run in a project-specific network. All the project files (PHP, other files, Mysql database files) will be stored locally (that means: on the host's file system) and not within the containers. Thus the containers could be deleted and recreated as needed without losing data.

To use _drush_ and _drupal console_ we will set up separate images and these images are used by `docker` to create containers on the fly when needed. 
> The reason why you set up your own images is: you need to volume the
> _drush_ and _drupal console_ settings (`.drush`; `.console` directories) and, as
> they run as root inside, change the default umode 022 (read, write by
> owner, read only by others) to 000 (read/write to all). Thus the user
> www-data in the apache container is able to write into directories
> that are not owned by www-data. This is not a security issue, as we
> work locally and use private networks only.

**So, let's go!**
 
> In this section the following instructions use **_bold italic_** text as
> placeholders. Replace these placeholders with real values when
> following the instructions.

* Create a new empty project *Project* in PhpStorm (File→New Project→Empty Project).

* Clone or download
  [the repo who's _README_ we're reading](https://github.com/iainhouston/drupal-docker)
  into this *Project*.

* We will get this directory structure:
    * *Project*
        * docker
            * drupalconsole
            * drush
            * node.js
            * Ubuntu_15.10
            * Ubuntu_16.04
        * www
            * docroot
            * tmp
            * private
               
    * The name of **_Project_** can be chosen as you like.
    
    * _docker_ contains build files and utilities for Docker
    
    * _www_ and subsequent directories will be created automatically during installation
    
        * _docroot_ is the root folder for Apache. Here all PHP-files and user created files will reside.
        
        * **tmp** is a directory for temporary files. It can be used as tmp-directory in Drupal (`admin/config/media/file-system`, use `../tmp`)
        
        * **private** is a directory for holding the private files in Drupal, but outside the web root (`admin/config/media/file-system`, use `../private`, in D8: settings.php). If you install backup_migrate, you will need it!
    
    * Following the subsequent steps Docker will create additional directories ***Project*/.log** and ***Project*/.mysql** to hold Apache log files and the Mysql database files, ***Project*/.console** to hold the settings for the Drupal console, ***Project*/.drush** to hold the settings for Drush and ***Project*/.sendmail** to collect the mails sent by Drupal (sendmail will be faked)

### Build the images

If this is your first project at all, you should build the images we need.
In PhpStorm run the scripts **build.sh** in docker/drupalconsole, docker/drush, docker/node.js, docker/Ubuntu_15.10, docker/Ubuntu_16.04 (select `build.sh`, then press `⌃⇧R`). These Images will be used in this project and reused in later projects.

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

* In PhpStorm start the script **startup.sh** in the "docker" folder (select `startup.sh`, then press `⌃⇧R`). When the containers are running (you can control it in PhpStorm by clicking on the Docker-tab at the lower left border) you can take the next steps.
> **Tip**  
In PhpStorm you can now easily add a run configuration with startup.sh. From the "Run" menu select "Edit Configurations", select the entry "startup.sh" and save it (click on the diskette-icon). If you then go to File→Settings→Tools→Startup Tasks you can add startup.sh to the list to start/stop the containers when you open/close the PhpStorm project. 

* Before we start to install our Drupal website we have to modify **/etc/hosts** to add the host names of our containers. Open a terminal in PhpStorm (the tab on the bottom left side) and enter
    ```
    cd docker
    sudo ./addhost.sudo.sh
    ```
    This will do the job.
    (Not required for *Docker for Mac*: see below.)


### Install Drupal website with default values


To install a Drupal website with default values execute the script
**drush-si.sh** in PhpStorm (select `drush-si.sh`, then press `⌃⇧R` to
run it). This will download Drupal if necessary, create a database if
necessary, install Drupal within this database and open the site in your
browser.
> To manually open your new site point your browser at “http://*APACHE_HOSTNAME*” (or “http://*APACHE_IP*” if you could not change /etc/hosts).  
But point to "localhost" when running *Docker for Mac* which does not offer a mapping of `docker-composer`'s `ipv4_address` in the Docker Server. Because of the way networking is implemented in *Docker for Mac*, you cannot see a docker0 interface in macOS. This interface is actually within *HyperKit*.
     
### Install Drupal with custom values

To download Drupal 7 or Drupal 8, execute the script **download_druspl7.sh** or **download_drupal8.sh** in PhpStorm (select the script, then press `⌃⇧R`). This will prepare the docroot with writable "custom" folders in the "modules" and the "themes" folder.
> **All files and directories in www/docroot will be deleted!**

* You want to use mysql as the database server have to create the database for Drupal by running the script **create_mysql_drupal_db.sh** in PhpStorm (select `create_mysql_drupal_db.sh`, then press `⌃⇧R`). **A database with same name will be dropped and recreated!**. If you want to use sqlite yu can skip this step.
    > **Tip**
    > To interact with the terminal window you have to click into it until you see a blinking cursor!

* Now you can open the website at “http://*APACHE_HOSTNAME*” (or “http://*APACHE_IP*” if you could not change /etc/hosts).

    > **Remember**  
    In Drupal the name of the mysql-host is not “localhost” nor *APACHE_HOSTNAME*, but “**mysql**”, that is the name of the connected mysql-service.

## Features of your new development environment
 
### Starting and stopping the environment in PhpStorm

To start the development environment for your project, run the **startup.sh** script as described above. This will create a container representing this environment. In the "Run" tab PhpStorm creates a tab for startup.sh. Here you can control the environment and even stop the containers.
 
### Debugging with PhpStorm

The Apache-container has been created with xdebug activated. So you can debug any web-session on this server in PhpStorm. To switch on/off debugging in the browser you will find a generator for bookmarklets to control php-debugging on this page https://www.jetbrains.com/phpstorm/marklets/ . Add these bookmarklets to your browser. To switch on/off debugging in PhpStorm you will find the icon “Start Listening for PHP Debug Connections” on the top right edge.

#### Start a debugging session

* Set debug breakpoints in PhpStorm

* Switch on “Start Listening for PHP Debug Connections” in PhpStorm

* Start your Browser

* Switch on debugging in your Browser

### Using Drush or the Drupal console in PhpStorm

To start drush or the drupal console open a terminal in PhpStorm. From the *Project* directory source **load-env** (by issuing ". load-env" or "source load-env" in the command line (without the quotation marks). This will set up aliases for drush and drupal to work with the containers.

> **Tip**  
> You can automate the loading of the environment by adding the following lines to your `~/.profile`.
> Thus every time you open a terminal in PhpStorm in this project or drag a project subfolder into the terminal window, the environment is loaded and the aliases/functions are set.
```bash
# load development environment
__profile_currentdir="$(pwd)"
while [ ! -e "./load-env" ] && [ "$(pwd)" != "/" ]; do
  cd ..
done
if [ -e "./load-env" ]; then
   . ./load-env
fi
cd $__profile_currentdir
```

> **Tip**  
If you issue `drush init` and/or `drupal init` once for your project you will also add some nice features from drush or the drupal console to shell: the shell prompt will show your git status, you will have code completion and so on.

### Open a shell in the mysql or apache container
You can directly issue commands in the apache or mysql containerin PhpStorm

* Select the "Docker" tab.

* Connect to Docker, if PhpStorm is not already connected (press the green arrow on the left side).

* Right-click on the apache or mysql-container (they must be green, otherwise start the containers with **startup.sh** described above

* Select "Exec" from the context menu.

* Select "create" and then enter "/bin/bash". Later "/bin/bash" will be available in the menu.

Now PhPStorm will open a new shell.
> **Hint**  
If more than one shell-tab is open for that container, PhpStorm has problems to activtate that tab. Select the most right tab titled "/bin/bash" **and then click into that tab** to activate it and set the focus on it. Otherwise it could be that you type into the most recent active editor window! 

### Moving/sharing the development environment

To move (or share) the development environment to another computer, simply copy the project folder. If necessary make some adjustments to **PROJECT_NAME** and/or **subnet** in file **environment**. Make sure, Docker and PhpStorm is installed and then run the **build.sh** scripts to create the images, run **addhost.sh** as root (sudo) and then execute **startup.sh** in PhpStorm.

To **share the definitions** of the project only share the "docker" folder of your project. On the taget machine follow the steps described in chapter "Overview".

## Bonus

### SASS compilation

In the docker directory you will find a file **watchers.xml**. In PhpStorm go to File→Settings→Tools→FileWatchers and then import **watchers.xml**. Activate one of the watchers (not both!). Now every sass and scss file will be compiled into a css file. Did you install Sass? No, you don't. Sass is provided by a Docker image! In the same way you can add Compass and many other tools to your environment.

### Node.js, npm and gulp

**Node**, **npm** and **gulp** are accessible via functions/aliases. Simply call node, npm or gulp on the command line as usual!
> **Hint**  
In most cases you have to install additional requirements to use a node.js project (e.g. in a Zen-theme). Then simply execute `npm install` in a terminal window in PhpStorm (don't forget to change into your node.js-project folder). This will install all needed plugins and utilites into a .bin-directory in your node.js project. `npm install gulp` will make gulp available on the command line. **You can't install gulp globally because there is no global context!** 
