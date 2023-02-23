.PHONY: all
all: hello.rom

hello.rom: hello.bin loader.bin addchecksum
	dd if=/dev/zero of=$@ bs=1 count=32768
	dd if=loader.bin of=$@ bs=1 conv=notrunc
	dd if=hello.bin of=$@ bs=1 conv=notrunc seek=512
	./addchecksum $@ || rm $@

loader.bin: loader.asm
	nasm $< -fbin -o $@

hello.bin: hello.asm addchecksum
	nasm $< -fbin -o $@

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	rm -rf addchecksum *.rom *.o *.elf *.bin

.PHONY: runqemu runbochs
runqemu: hello.rom
	qemu-system-i386  -net none -option-rom hello.rom

runbochs: hello.rom
	bochs -qf bochs.cfg
