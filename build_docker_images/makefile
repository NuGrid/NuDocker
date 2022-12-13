# make nudome images: select target and make, like this:
# make nudome14

# this is a template to create new combinations of linux and mesasdk
nudomexx : LINUXVERS = 20.04
nudomexx : IMAGENAME = nugrid/nudome:20.031
nudomexx : MESAVERS  = 20.3.1
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
nudome14 : LINUXVERS = 14.04
nudome14 : IMAGENAME = nugrid/nudome:14.0a
nudome14 : MESAVERS  = 20140715
nudome14 : TEMPLATE = Dockerfile_template.14
nudome14 : nudome

# building 2020 versions
nudome20.031 : LINUXVERS = 20.04
nudome20.031 : IMAGENAME = nugrid/nudome:20.031a
nudome20.031 : MESAVERS  = 20.3.1
nudome20.031 : TEMPLATE = Dockerfile_template.20
nudome20.031 : nudome

nudome20.1 : LINUXVERS = 20.04
nudome20.1 : IMAGENAME = nugrid/nudome:20.1a
nudome20.1 : MESAVERS  = 21.4.1
nudome20.1 : TEMPLATE  = Dockerfile_template.20
nudome20.1 : nudome






nudome: 
	sed -e s/mm.nn/$(LINUXVERS)/ -e  s/yyyymmdd/$(MESAVERS)/ -e s/x.x.x/$(MPIVERS)/  \
        $(TEMPLATE) > Dockerfile
	docker build  -t $(IMAGENAME) .
