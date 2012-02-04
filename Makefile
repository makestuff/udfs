SUBDIRS := server udfs_rom uptx_rom firmware xbm2bbc d6502

all: FORCE
	for i in $(SUBDIRS); do make -C $$i; done

clean: FORCE
	for i in $(SUBDIRS); do make -C $$i clean; done

FORCE: