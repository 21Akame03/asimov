default: run

build/multiboot_header.o: multiboot_header.asm
	mkdir -p build
	nasm -f elf64 multiboot_header.asm -o ./build/multiboot_header.o

build/boot.o: boot.asm
	nasm -f elf64 boot.asm -o ./build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
	ld -n -o ./build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/asimov.iso: build/kernel.bin grub.cfg
	mkdir -p isofiles/boot/grub
	cp grub.cfg isofiles/boot/grub
	cp build/kernel.bin isofiles/boot
	grub2-mkrescue -o build/asimov.iso isofiles

run: build/asimov.iso
	qemu-system-x86_64 -cdrom build/asimov.iso

clean:
	rm -rf ./build
