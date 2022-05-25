# make nudome images

# this is a template to create new combinations of linux and mesasdk
nudomexx : LINUXVERS = 20.04
nudomexx : IMAGENAME = nugrid/nudome:20.0
nudomexx : MESAVERS  = 20.12.1
nudomexx : nudome

# building the 2018 version
nudome18 : LINUXVERS = 18.04
nudome18 : IMAGENAME = nugrid/nudome:18.0
nudome18 : MESAVERS  = 20180822
nudome18 : nudome

# building the 2016 version
nudome16 : LINUXVERS = 16.04
nudome16 : IMAGENAME = nugrid/nudome:16.0
nudome16 : MESAVERS  = 20160129
nudome16 : nudome

# building the 2014 version
nudome14 : LINUXVERS = 12.04
nudome14 : IMAGENAME = nugrid/nudome:14.0
nudome14 : MESAVERS  = 20141212
nudome14 : nudome

nudome: 
	sed -e s/mm.nn/$(LINUXVERS)/ -e  s/yyyymmdd/$(MESAVERS)/ -e s/x.x.x/$(MPIVERS)/ -e s/vx.x/v$(MPIV)/ \
        Dockerfile_template > Dockerfile
	docker build  -t $(IMAGENAME) .
