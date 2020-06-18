# make nudome images

# this is a template to create new combinations of linux and mesasdk
nudomexx : LINUXVERS = 18.04
nudomexx : IMAGENAME = nugrid/nudome:xx
nudomexx : MESAVERS  = 20180822
nudomexx : MPIVERS   = 4.0.3
nudomexx : MPIV      = 4.0
nudomexx : nudome

# building the 2018 version
nudome18 : LINUXVERS = 18.04
nudome18 : IMAGENAME = nugrid/nudome:18.0
nudome18 : MESAVERS  = 20180822
nudome18 : MPIVERS   = 4.0.3
nudome18 : MPIV      = 4.0
nudome18 : nudome

# building the 2016 version
nudome16 : LINUXVERS = 16.04
nudome16 : IMAGENAME = nugrid/nudome:16.0
nudome16 : MESAVERS  = 20160129
nudome16 : MPIVERS   = 4.0.3
nudome16 : MPIV      = 4.0
nudome16 : nudome

# building the 2014 version
nudome14 : LINUXVERS = 12.04
nudome14 : IMAGENAME = nugrid/nudome:14.0
nudome14 : MESAVERS  = 20141212
nudome14 : MPIVERS   = 4.0.3
nudomexx : MPIV      = 4.0
nudome14 : nudome

nudome: 
	sed -e s/mm.nn/$(LINUXVERS)/ -e  s/yyyymmdd/$(MESAVERS)/ -e s/x.x.x/$(MPIVERS)/ -e s/vx.x/v$(MPIV)/ \
        Dockerfile_template > Dockerfile
	docker build  -t $(IMAGENAME) .
