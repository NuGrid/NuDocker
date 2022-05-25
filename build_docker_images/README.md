# Build NuDocker build_docker_images

## Files
File | Comment
-----|--------
`Docker_template` | make will use information in targets given in `makefile` and create Dockerfile to use with `docker build`
`Dockerfile.20` | Dockerfile for `nudome:20` images


## Instructions
* To make image use `make target` where `target` is, for example `nudome14`.
* To create new image start with creating `Dockerfile` from target `nudomexx`. This may require some manual editing and leads to version-specific DOckerfiles, such as `Dockerfile.20`. 
