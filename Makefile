.PHONY: all
all: hello.rom addchecksum

hello.rom: hello.asm addchecksum
	nasm $< -fbin -o $@.tmp
	./addchecksum $@.tmp || rm $@.tmp
	dd if=/dev/zero of=$@ bs=1 count=65536
	dd if=$@.tmp of=$@ bs=1 conv=notrunc

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	rm -rf addchecksum *.rom *.o *.elf

.PHONY: runqemu
runqemu: hello.rom
	qemu-system-i386  -net none -option-rom hello.rom
