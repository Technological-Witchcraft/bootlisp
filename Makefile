.PHONY:
run: image
	qemu-system-x86_64 image

IMAGE_SIZE = 33280
image: boot_sector.bin stage1.lisp
	cat boot_sector.bin stage1.lisp > image
	truncate -s ${IMAGE_SIZE} image

boot_sector.bin: boot_sector.asm
	nasm -f bin boot_sector.asm -o boot_sector.bin
