**This project is still young. Please report any errors, ommissions or suggestions for improvements.**

# NuDocker
Run older and newer versions of [MESA](http://mesa.sourceforge.net) in Ubuntu-based Docker containers.

See also Evan Bauer's [MESA-Docker repository](https://github.com/evbauer/MESA-Docker) and the [MESA marketplace](http://www.mesastars.org).

## Motivation and goals
MESA stellar evolution simulations are the basis of many of the NuGrid collaboration activitities. The motivation behind the capability of running MESA in Docker containers is primarily one of **reproducibility of science**. MESA is a _big_ code with lots of modules and dependencies that all have to play perfectly together. Rich Townsend's [MESA SDK](http://www.astro.wisc.edu/~townsend/static.php?ref=mesasdk) has significantly taken the pain out of compiling MESA. Nevertheless, it is still difficult to maintain on one actual computer the capability to run different versions of MESAS, especially going back to the older versions. At the same time, a lot of important results have been obtained with these older revisions which in many cases are not obsolete, but just different MESA flavours. 

The docker technology provides _containers_ in which a particular version of MESA can run, and to preserve the required system environment for future use. While Evan's Docker repository is geared toward uses on all operating systems this project has been tested on Mac OS and Linux host systems only. However, we do provide the Dockerfiles that are the bases for building the Docker images, and we do provide the images of course as well on the Docker hub repository. The goal of this repository is rather to provide Docker images that allow to run a wide range of MESA versions, at this point as far back as version 4942. Other combinations of Linux OS and MESA SDK can also be easily generated from the Dockerfiles.

Going back further than 4942 is possible in principle, but we are getting to the time before MESA SDK, and maybe even when the intel fortran compiler was the prefered option. For the time being this project does not support earlier versions. However, using the provided Dockerfiles is a good starting point for the ambitious MESA engineer to push back further into the history of MESA revisions.  Any success in that direction should trigger a pull request in this repo. 

## Versions
There are three images to run MESA: _nudome14_, _nudome16_ and _nudome18_. The number NN in the name _nudomeNN_ indicates the year from which the MESA SDK has been taken. The following mesa versions have been tested in these Docker images:

Image | mesa versions
------|--------------
nudome14 | r7624, r6188, r4942
nudome16 | r10398, r10000, r9793, r9575, r8845, r8118
nudome18 | r10398, r10000 
 
In each case the test consisted of compiling and running `test_suite/7M_prems_to_AGB`. It is likely that other versions will run as well in containers from these images.

## User guide

### Prerequisites
1. Install Docker on your host OS. Test your installation. Usually that means that you receive some encouraging success message when entering the command `docker run hello-world` at the terminal.
2. Download a MESA code version `nnnnn` (where `nnnnn` stands for the revision number) as listed on the [MESA News Archive](http://mesa.sourceforge.net/news.html); unzip the ZIP file. For the instructions below it assumed (but not required) that the MESA code tree is extracted into a directory called `mesa-rnnnnn`.

### Usage
In order to use one of the three docker images only the `bin/start_and_login.sh` (and maybe the `bin/login.sh`) is needed. 

#### Starting a container and login
You can place the scripts in the `bin` directory in your own `$HOME/bin` directory, or add the path to this bin directory in your repository to your `$PATH` environment variable, or just directly specify the script with a relative or absolute path. If you are in the root directory of the _NuDOcker_ repository you start a container and login with the `bin/start_and_login.sh` script:

```
Usage: start_and_login.sh [-m /host/dir/to/mnt/for/runs] ARG1 ARG2 ARG3

ARG1: name of the container 
      Recommend to include the mesa version number, such as 'mesa-r9793'.
ARG2: image name ID
      There are three options: nudome14, nudome16 or nudome18.
ARG3: full path to the mesa code directory on your host system
      Examples: '/path/to/MESA/mesa-r9793' or '$HOME/MESA/mesa-r9793'
-m  : optionally provide full path to dir (e.g. for runs) to be mounted in
      '$HOME/mnt'
```

There are two different use cases:
1. The default is to just mount the full path to the mesa code directory (ARG3) into the container where it appears as `$HOME/mesa`, i.e. the dir `mesa` in the user home dir inside the container. A user could use the home dir inside the container for actual runs, but this storage is not accessible from the host. Instead the typical use of this mode is to run in 
	- the `star/test_suite` dir, or
	- to create a mesa run dir inside the mesa home dir (on the container) which is on the host the mesa source direcory tree that was specified during mount time, such as `user@mesa-r9575:~/mesa$ mkdir mesa_runs`, and then create there your mesa run directory, e.g. by copy from the `star/test_suite` directory.
2. The second usage scenario is to use the `-m` option to specify a second directory on the host system, e.g. on an external hard drive or scratch space. This will be mounted in the container home directory under `$HOME/mnt`, and run directories can be created there. 

In both cases the environment variable `MESA_DIR` is set inside the container to `$HOME/mesa`.

	
	
##### Example: 
```
bin/start_and_login.sh mesa-r9331 nugrid/nudome16 /Volumes/Astro/L/CODE/MESA/mesa-r9575
```
starts a container of the image nugrid/nudome16 and mounts the host directory `/Volumes/Astro/L/CODE/MESA/mesa-r9575` which contains the mesa source directory of version 9575. The assigned container name is `mesa-r9331`. 

```
bin/start_and_login.sh -m /scratch/data17 mesa-r9331 nugrid/nudome16 /Volumes/Astro/L/CODE/MESA/mesa-r9575
```
does the same as above, but in addition it mounts `/scratch/data17` in the container home directory under `$HOME/mnt` where it can be used to run the MESA code. 

#### Exit, login again or kill the docker container

* When you exit the container (command line `exit`) you will leave the container, which will continue to exist in status _Exited_. 
* To re-enter the container use the `login.sh` script: `bin/login.sh container_name`
* To permanently end the container _remove_ it with command line `docker rm container_name`. 

The `container_name` has been specified during the initial start of the container, and is also the hostname. It is listed in the column `NAMES` of the command `docker ps -a` (see below).

## Visualization of results
At this point the nudome images do not provide any tools that may be used for plotting. This would be done on the host system through the many available tools available e.g. from the [MESA marketplace](http://mesastar.org). One such tool is [NuGrid's NuGridPy](https://nugrid.github.io/NuGridPy) that can be easily installed via the [NuGridPy pip package](https://pypi.org/project/NuGridpy), see also [usage examples](https://github.com/NuGrid/wendi-examples): [example 1](https://github.com/NuGrid/wendi-examples/blob/master/Stellar%20evolution%20and%20nucleosynthesis%20data/Star_explore.ipynb), [example2](https://github.com/NuGrid/wendi-examples/blob/master/Stellar%20evolution%20and%20nucleosynthesis%20data/Examples/Teaching_explore_MESA_stellar_evolution.ipynb). 


## Docker essentials
Docker containers are actually doing things, and they are launched by activating a Docker image. We have three Docker images, _nomedo14_, _nomedo16_ and _nomedo18_. You can launch as many containers of each of these images as you like. The containers are into what you log in and where you actually run MESA.

These are the only docker commands you may need:

Docker command | explanation
---------------|-------------
`docker -ps -a` | list all Docker containers, including their names
`docker rm container_name` | remove container with name `container_name`


## Building the docker images
If you want to try different combinations of Ubuntu, MESA-SDK versions, or would like to add additional software to the nudome images build your own Docker image. In the `build_docker_images` directory use the `make` command to build either of the targets `nudome14`, `nudome16` or `nudome18`. Edit the `makefile` to specify version numbers for the template target `nudomexx`. 

The `make` command will replace insert the version numbers into the `Dockerfile` based on the `Dockerfile_template`. Any additional packages you may want to install using Ubuntu's package manager `apt-get` may just be added to the `apt_packages_nudome.txt` file.

##### Example:
```
make nudome14
```
will build the `nudome14` Docker image.

## Roadmap
* add capability to run PPN
* add jupyter notebook server that can be accessed from host to integrate analysis tools in the form of notebooks
