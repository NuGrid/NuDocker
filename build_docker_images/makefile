nudomexx : LINUXVERS = 18.04
nudomexx : IMAGENAME = nugrid/nudome18
nudomexx : MESAVERS  = 20180822
nudomexx : nudome

nudome18 : LINUXVERS = 18.04
nudome18 : IMAGENAME = nugrid/nudome18
nudome18 : MESAVERS  = 20180822
nudome18 : nudome

nudome16 : LINUXVERS = 16.04
nudome16 : IMAGENAME = nugrid/nudome16
nudome16 : MESAVERS  = 20160129
nudome16 : nudome

nudome14 : LINUXVERS = 12.04
nudome14 : IMAGENAME = nugrid/nudome14
nudome14 : MESAVERS  = 20141212
nudome14 : nudome

nudome: 
	sed -e s/mm.nn/$(LINUXVERS)/ -e  s/yyyymmdd/$(MESAVERS)/ Dockerfile_template  > Dockerfile
	docker build  -t $(IMAGENAME) .
