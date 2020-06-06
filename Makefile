.PHONY:
run: boot_sector.bin
	qemu-system-x86_64 boot_sector.bin

boot_sector.bin: boot_sector.asm
	nasm -f bin boot_sector.asm -o boot_sector.bin
