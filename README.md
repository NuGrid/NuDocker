# NuMesaDocker
Run older and newer versions of [MESA](http://mesa.sourceforge.net) in Ubuntu-based Docker containers.

See also Evan Bauer's [MESA-Docker repository](https://github.com/evbauer/MESA-Docker) and the [MESA marketplace](http://www.mesastars.org).

## Motivation and goals
The motivation behind the capability of running MESA in Docker containers is primarily one of _reproducibility of science_. MESA is a _big_ code with lots of modules and dependencies that all have to play perfectly together. Rich Townsend's [MESA SDK](http://www.astro.wisc.edu/~townsend/static.php?ref=mesasdk) has significantly taken the pain out of compiling MESA. Nevertheless, it is still difficult to maintain on one actual computer the capability to run different versions of MESAS, especially going back to the older versions. At the same time, a lot of important results have been obtained with these older revisions which in many cases are not obsolete, but just different MESA flavours. 

The docker technology is ideally suited to provide _containers_ in which a particular version of MESA can run, and to conserve the present system environment for future use. While Evan's Docker repository is geared toward uses on all operating systems this project has been tested on Mac OS and Linux host systems only. However, we do provide the Dockerfiles that are the bases of building the Docker images, and we do provide the images of course as well on the Docker hub repository. The goal of this repository is rather to provide Docker images that allow to run MESA version as far back as version 4942. Going back further than that is possible in principle, but we are getting to the time before MESA SDK, and maybe even when the intel fortran compiler was the prefered option. For the time being this project does not support earlier versions, however, using the provided Dockerfiles is a good starting point for the ambitious MESA engineer to push back further into the history of MESA revisions. Any success in that direction is encouraged to launch a pull request in this repo.



