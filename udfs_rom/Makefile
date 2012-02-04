all: udfs_rom.bin

udfs_rom.bin: udfs_rom.s
	acme $<

clean: FORCE
	rm -f udfs_rom.bin

FORCE:
