.PHONY: all
all: hello.rom addchecksum

hello.rom: hello.asm addchecksum
	nasm $< -fbin -o $@
	./addchecksum $@ || rm $@

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	rm -rf addchecksum *.rom *.o *.elf

.PHONY: runqemu
runqemu: hello.rom
	qemu-system-i386  -net none -option-rom hello.rom
