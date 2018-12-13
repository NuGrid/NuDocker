**This project is still young. Please report any errors, ommissions or suggestions for improvements.**


# NuDocker
Run older and newer versions of [MESA](http://mesa.sourceforge.net) in Ubuntu-based Docker containers.

See also Evan Bauer's [MESA-Docker repository](https://github.com/evbauer/MESA-Docker) and the [MESA marketplace](http://www.mesastars.org).

## Motivation and goals
MESA stellar evolution simulations are the basis of many of the NuGrid collaboration activitities. The motivation behind the capability of running MESA in Docker containers is primarily one of **reproducibility of science**. MESA is a _big_ code with lots of modules and dependencies that all have to play perfectly together. Rich Townsend's [MESA SDK](http://www.astro.wisc.edu/~townsend/static.php?ref=mesasdk) has significantly taken the pain out of compiling MESA. Nevertheless, it is still difficult to maintain on one actual computer the capability to run different versions of MESAS, especially going back to the older versions. At the same time, a lot of important results have been obtained with these older revisions which in many cases are not obsolete, but just different MESA flavours. 

The docker technology provides _containers_ in which a particular version of MESA can run, and to preserve the required system environment for future use. While Evan's Docker repository is geared toward uses on all operating systems this project has been tested on Mac OS and Linux host systems only. However, we do provide the Dockerfiles that are the bases for building the Docker images, and we do provide the images of course as well on the Docker hub repository. The goal of this repository is rather to provide Docker images that allow to run a wide range of MESA versions, at this point as far back as version 4942. Other combinations of Linux OS and MESA SDK can also be easily generated from the Dockerfiles.

Going back further than 4942 is possible in principle, but we are getting to the time before MESA SDK, and maybe even when the intel fortran compiler was the prefered option. For the time being this project does not support earlier versions. However, using the provided Dockerfiles is a good starting point for the ambitious MESA engineer to push back further into the history of MESA revisions.  Any success in that direction should trigger a pull request in this repo. 

## Versions
There are three versions of the _nudome:yy.v_ image  to run MESA. The major version number yy indicates the year from which the MESA SDK has been taken. The minor version number v may indicates updates or variations. The following mesa versions have been tested in the _nudome_ Docker image:

Version | mesa versions
------|--------------
14.0 | r7624, r5329, r6188, r4942
16.0 | r10398, r10000, r9793, r9575, r8845, r8118
18.0 | r10398, r10000 
 
In each case the test consisted of compiling and running `test_suite/7M_prems_to_AGB`. It is likely that other versions will run as well in containers from these images.

## User guide

### Prerequisites
1. Install Docker on the host OS. Test the installation. Usually that means that receiving some encouraging success message when entering the command `docker run hello-world` at the terminal.
2. Download a MESA code version `nnnnn` (where `nnnnn` stands for the revision number) as listed on the [MESA News Archive](http://mesa.sourceforge.net/news.html); unzip the ZIP file, e.g. `unzip mesa-r5329.zip` which will expand the mesa source directory `mesa-r5239`.

### Usage
In order to use one of the three docker images only the `bin/start_and_login.sh` (and maybe the `bin/login.sh`) is needed. 

#### Starting a container and login

The scripts in the `bin` directory can be placed in the user's
`$HOME/bin` directory, or the path to this bin directory is added to
the `$PATH` environment variable, or the the script is directly called with 
the relative or absolute path. From the top-level directory of
the _NuDocker_ repository the container can be started and logged-in with the
`bin/start_and_login.sh` script:

```
Usage: start_and_login.sh [-m /host/dir/to/mnt/for/runs] ARG1 ARG2 ARG3

ARG1: name of the container 
      Recommend name is the default mesa source tree directory name including
      the mesa version number, such as 'mesa-r9793'.
ARG2: image name
      The name is 'nudome:1n.0' where n=4, 6 or 8.
ARG3: full path to the mesa code directory on your host system
      Examples: '/path/to/MESA/mesa-r9793' or '$HOME/MESA/mesa-r9793'
-m  : optionally provide full path to dir (e.g. for runs) to be mounted in
      '$HOME/mnt'
```

The default usage scenario is to run either a test_suite case inside
the mesa source tree, or to create a run directory at top level of the
mesa source tree. For this, the default would mount the source code
directory (`ARG3`) into the container where it appears as `$HOME/mesa`,
i.e. the dir `mesa` in the user home dir inside the
container. Optionally a separate host directory for run directories
can be mounted with the `-m` option. This will be mounted in the
container home directory under `$HOME/mnt`.

The environment variable `MESA_DIR` is set inside the container to `$HOME/mesa`.

##### Example: 
```
bin/start_and_login.sh mesa-r9575 nugrid/nudome:16.0 /Volumes/Astro/L/CODE/MESA/mesa-r9575
```
starts a container of the image nugrid/nudome:16.0 and mounts the host directory `/Volumes/Astro/L/CODE/MESA/mesa-r9575` which contains the mesa source directory of version 9575. The assigned container name is `mesa-r9575`. 

```
bin/start_and_login.sh -m /scratch/data17 mesa-r9575 nugrid/nudome:16.0 /Volumes/Astro/L/CODE/MESA/mesa-r9575
```
does the same as above, but in addition it mounts `/scratch/data17` in the container home directory under `$HOME/mnt` where mesa run directories can be placed. 

#### Exit, login again or kill the docker container

* When exiting the container (command line `exit`) it will continue to exist in status _Exited_. 
* The conatiner can be re-entered with the `login.sh` script: `bin/login.sh container_name`
* The command `docker rm container_name` permanently ends the container.
* The command `docker exec -t -i container_name /bin/bash` would create a second login shell into an existing and running container with the name `container_name`.

The `container_name` has been specified during the initial start of the container, and is also the hostname. It is listed in the column `NAMES` of the command `docker ps -a` (see below).

## Visualization of results 

At this point the nudome image does not provide any tools that may be used for plotting. This would be done on the host system through the many available tools available e.g. from
the [MESA marketplace](http://mesastar.org). One such tool is
[NuGrid's NuGridPy](https://nugrid.github.io/NuGridPy) that can be
easily installed via the [NuGridPy pip
package](https://pypi.org/project/NuGridpy), see also [usage
examples](https://github.com/NuGrid/wendi-examples): [example
1](https://github.com/NuGrid/wendi-examples/blob/master/Stellar%20evolution%20and%20nucleosynthesis%20data/Star_explore.ipynb),
[example2](https://github.com/NuGrid/wendi-examples/blob/master/Stellar%20evolution%20and%20nucleosynthesis%20data/Examples/Teaching_explore_MESA_stellar_evolution.ipynb).


## Docker essentials

Docker containers are actually doing things, and they are launched by
activating a Docker image. Containers are instances of images. The
_nudome_ image comes in three versions. You can launch as many
containers of each of these image versions as you like, just give them
different names. The containers are what you login to and where you
actually run MESA.

These are the only docker commands you may need:

Docker command | explanation
---------------|-------------
`docker -ps -a` | list all Docker containers, including their names
`docker rm container_name` | remove container with name `container_name`


## Building the docker images

If you want to try different combinations of Ubuntu and MESA SDK
versions, or would like to add additional software to the nudome
image build your own Docker image. In the `build_docker_images`
directory use the `make` command to build the three _nudome_
versions. Edit the `makefile` to specify version numbers for the
template target `nudomexx`.

The `make` command will insert the MESA SDK and Ubuntu version numbers into the
`Dockerfile` based on the `Dockerfile_template`. Any additional
packages you may want to install using Ubuntu's package manager
`apt-get` may just be added to the `apt_packages_nudome.txt` file.

##### Example:

```
make nudome14
```
will build the `nudome:14.0` Docker image. The makefile target names of version `16.0` and `18.0` are `nudome16` and `nudome18` respectively. A template target `nudomexx` is provided for new builds with different version combinations and/or other modifications. 

## Known issues

* Most testing has been done on Mac OSX hosts (OSX 10.13.6, Docker version 18.06.1-ce-mac73).
* On Linux host system, possibly depending on the setup of your docker installation, you may have to set the permissions on the mounted host directories (including the mesa host dir) to `world`, such as `chmod -R ugo+rwX mesa-rnnnn`.
* On Linux host system, possibly depending on the setup of your docker installation, files written as the user in the Docker container may have a user and group ID different than the one the user has on the host system.

## Roadmap
* Add capability to run PPN.
* Add jupyter notebook server that can be accessed from host to integrate analysis tools in the form of notebooks.
