all: uptx_rom.bin

uptx_rom.bin: uptx_rom.s
	acme $<

clean: FORCE
	rm -f uptx_rom.bin

FORCE:
