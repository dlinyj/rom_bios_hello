.PHONY: all
AS=nasm

all: hello.rom addchecksum hello.com

hello.rom: hello.asm addchecksum
	$(AS) $< -fbin -o $@
	./addchecksum $@ || rm $@

hello.com: hello.asm
	$(AS) -f bin -dCOM_FILE $< -fbin -o $@

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	rm -rf addchecksum *.rom *.o *.elf *.com

.PHONY: runqemu rundosbox
runqemu: hello.rom
	qemu-system-i386  -net none -option-rom hello.rom

rundosbox: hello.com
	dosbox hello.com
