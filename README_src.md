[![DOI](https://zenodo.org/badge/151356323.svg)](https://zenodo.org/badge/latestdoi/151356323)

# NuDocker
## A virtual research environment for computational nuclear and stellar astrophysics

This repository hosts a suite for containerizing and running older or newer versions of [MESA](http://mesa.sourceforge.net) in Ubuntu-based Docker containers. The Dockerfile also allows for running and testing of other NuGrid applications, such as NuPPN, in the same docker container.

See also Evan Bauer's [MESA-Docker repository](https://github.com/evbauer/MESA-Docker) and the [MESA marketplace](http://www.mesastars.org).

## Motivation and goals
MESA stellar evolution simulations are the basis of many of the NuGrid collaboration activitities. The motivation behind the capability of running MESA in Docker containers is primarily one of **reproducibility of science**. MESA is a _big_ code with lots of modules and dependencies that all have to play perfectly together. Rich Townsend's [MESA SDK](http://www.astro.wisc.edu/~townsend/static.php?ref=mesasdk) has significantly taken the pain out of compiling MESA. Nevertheless, it is still difficult to maintain on one actual computer the capability to run different versions of MESAS, especially going back to the older versions. At the same time, a lot of important results have been obtained with these older revisions which in many cases are not obsolete, but just different MESA flavours. 

The docker technology provides _containers_ in which a particular version of MESA can run, and to preserve the required system environment for future use. While Evan's Docker repository is geared toward uses on all operating systems this project has been tested on Mac OS and Linux host systems only. However, we do provide the Dockerfiles that are the bases for building the Docker images, and we do provide the images of course as well on the Docker hub repository. The goal of this repository is rather to provide Docker images that allow to run a wide range of MESA versions, at this point as far back as version 4942. Other combinations of Linux OS and MESA SDK can also be easily generated from the Dockerfiles.

Going back further than 4942 is possible in principle, but we are getting to the time before MESA SDK, and maybe even when the intel fortran compiler was the prefered option. For the time being this project does not support earlier versions. However, using the provided Dockerfiles is a good starting point for the ambitious MESA engineer to push back further into the history of MESA revisions.  Any success in that direction should trigger a pull request in this repo. 

## Versions
There are three versions of the _nudome:yy.v_ image  to run MESA. The major version number yy indicates the year from which the MESA SDK has been taken. The minor version number v may indicates updates or variations. The following mesa versions have been tested in the _nudome_ Docker image:

NuDome version | MesaSDK version | MESA versions
------|--------------|--------------------
14.0 | 20141212 | r4942,  r5329, r6188, r6794, r7624
16.0 | 20160129 | r8118, r8845, r9575, r9793, r10000, r10398
18.0 | 20180822 | r10000 , r10398, r12115
20.031 | 20.3.1  |  r12778
20.0 | 20.12.1  |  not used right now
20.1 | 21.4.1  |  r15140, r22.05.1, r22.11.1

In each case the test consisted of compiling and running `test_suite/7M_prems_to_AGB`. It is likely that other versions will run as well in containers from these images.

## Quickstart

Six quick steps to success (more details provided below):
1. Download and install docker
2. Execute the terminal command `% docker run hello-world` to check that Docker installation works
3. Download und unpack an old mesa version, assuming mesa-r5329 in these instructions
4. Download this git repo, assuming its on your Desktop in these instructions, e.g. `git clone https://github.com/NuGrid/NuDocker.git`
5. Change directory into the NuDocker repo dir, e.g. `cd ~/tmp/NuDocker` (change this command according to where you have cloned the NuDocker repo into). 
6. Execute the terminal command `% ./bin/start_and_login.sh mesa-r5329 nugrid/nudome:16.0 /Users/YOURUSERNAME/Desktop/mesa-r5329` where you would change the last path name to where **you** have saved the mesa source tree **in step 3 above**, and where you select the correct version of nudome as specified in table below and where you select as a second argument the name for your docker containter.
7. Build mesa
```
% cd mesa
% ./install
```

## User guide

### Prerequisites
1. Install Docker on the host OS. Test the installation. Usually that means that receiving some encouraging success message when entering the command `docker run hello-world` at the terminal.
2. Download a MESA code version `nnnnn` (where `nnnnn` stands for the revision number) as listed on the [MESA News Archive](http://mesa.sourceforge.net/news.html) or on the [MESA release page on sourceforge](https://sourceforge.net/projects/mesa/files/releases)
      * you can use the command line tool `wget` as in `wget https://zenodo.org/records/2630796/files/mesa-r7624.zip`
      * unzip the ZIP file, e.g. `unzip mesa-r5329.zip` which will expand the mesa source directory `mesa-r5239`.

### Usage
In order to use one of the provided docker images only the `bin/start_and_login.sh` (and maybe the `bin/login.sh`) is needed. The required docker images will be automatically downloaded.

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
      The name is 'nugrid/nudome:1n.0' where n=4, 6 or 8. If you have built a 
      local image the name maybe be different, see `docker images`
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

The environment variable `MESA_DIR` is set inside the container to `$HOME/mesa`. Depending on your Docker setup and host hardware you may to set `OMP_NUM_THREADS` to the number of cores to use.

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

NuDocker has not been tested to work with pgplot. However, it could probably be configured to do so. If anyone makes progress in this direction please do a pull request. In Dec 2022 these were some search starting points:
- https://l10nn.medium.com/running-x11-applications-with-docker-75133178d090
- https://github.com/mviereck/x11docker


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

## Running Docker images in Apptainer on Clusters
The easiest way to run MESA on a cluster is to use NuDocker Docker image via the Apptainer system. Apptainer allows you to create Apptainer images from Docker images and run these as Apptainer containers on a cluster without having to install Docker on the cluster. The Apptainer system is available, for example, on the Canadian DRAC clusters and on Frontera at TACC.

Here are the instructions to run the NuDocker image on the DRAC clusters with the Apptainer system:
1. Log in to the DRAC cluster.
2. Load the Apptainer module: `module load apptainer/1.2.2`
3. Build a new Apptainer image from the NuDocker image
      * for example `apptainer build nudome:14.0.sif docker://nugrid/nudome:14.0`
      * `nugrid/nudome:14.0` is the docker image name on the [Docker Hub](https://hub.docker.com/repository/docker/nugrid/nudome/tags) 
4. Start the Apptainer container with something like: `apptainer shell -B /path/to/mesa  --no-home /path/to/Apptainers/nudome:14.0.sif`

You would then have to do some manual setup of the environment in the container, such as setting the `MESA_SDK` environment variable, etc. These steps have been combined in the script `apptainer_mesa.sh` located in the `bin` directory. You can use this script to run the NuDocker image on the DRAC clusters, and with little modifications, such as PATH names defined in the script, on other clusters with the Apptainer system.

This script sets up and launches an Apptainer container for running MESA with the correct environment. It first defines key paths for the Apptainer image, MESA source directory, and a scratch directory. Before launching, it prints information about the setup, including where MESA will be mounted inside the container and how the environment will be configured.

When executed, it mounts the MESA source directory to /home/user/mesa inside the container and ensures the scratch directory is accessible at the same path. It sets necessary environment variables, including MESA_DIR and MESASDK_ROOT, OMP_NUM_THREADS. Inside the container, it sources the MESA SDK initialization script, changes the working directory to the MESA source directory, and opens an interactive shell for the user.


## Performance
At some point tests were made to run a recent (`r22.xxx`) version MESA natively on Mac Intel and in NuDocker and it was found that that latter is 5-10 % faster. 

Below are a few additional performance numbers:

hardware|native/nudome | task | time
-------|----------------|--------|------
Intel Skylake 2GHz in Arbutus virtual workstation | compile after clean | 8m32.523s
Intel Skylake 2GHz in Arbutus virtual workstation  | `7M_prems_to_AGB$ time ./rn > out&` |13m2.797s
Apple M2 |   compile after clean | 33m31s
Apple M2 | `7M_prems_to_AGB$ time ./rn > out&` |1hr59m
Apple i7 2.3GHz |   compile after clean | 23m30s
Apple i7 2.3GHz |    `7M_prems_to_AGB$ time ./rn > out&` | 9m44s
Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz |  `7M_prems_to_AGB$ time ./rn > out&` | 3m44.164s
Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz | compile after clean | 7m28.185s


### Notes:
* All tests with `OMP_NUM_THREADS=4` which is the default in all `nudome` Docker images
* Times reported are the `real` output of the `time` command
* All tests use linux/amd64 image `nugrid/nudome:20.031` and MESA version 12778
* Arbutus virtual workstation is in the [Arbutus Compute Canada cloud at Univeristy of Victoria](https://docs.alliancecan.ca/wiki/Cloud_resources#Arbutus_cloud).

### Apple Silicon (M1/M2)
The new Apple machines use the M1/M2 processors dubbed _Apple silicon_. These are Arm-based architectures. Docker will run the nudome `linux/amd64` Docker images on Apple silicon in emulation, but it is slow. Running MESA version 12778 in nugrid/nudome:20.031  on Apple silicon has been tested and it works and gives the same answer `;-)`, see above for some performance numbers. 

Unfortunately there is apparently no straight-forward way to get decent performance with Docker images on Apple silicon. If someone knows how to do this please get in touch. Trying to build a Docker images on Apple silicon using a Dockerfile that have built Intel images using Intel Mesa SDK will not work. In principle, it is possible to build Docker images for multiple platforms, but it gets a bit complicated and it is not clear that the performance will be better, maybe it will. 


## Known issues
* Most testing has been done on Mac OSX hosts (OSX 10.13.6, Docker version 18.06.1-ce-mac73).
* On Linux host system, possibly depending on the setup of your docker installation, you may have to set the permissions on the mounted host directories (including the mesa host dir) to `world`, such as `chmod -R ugo+rwX mesa-rnnnn`. 
* On Linux host system, possibly depending on the setup of your docker installation, files written as the user in the Docker container may have a user and group ID different than the one the user has on the host system. 


## Roadmap
* Add capability to run PPN.
* Add jupyter notebook server that can be accessed from host to integrate analysis tools in the form of notebooks.
