# BerkeLiumOS
#
# BootLoader Makefile

CC=gcc
LD=ld
LDFILE=loader.lds
OBJCOPY=objcopy

all: boot.img

boot.img: bootsec.bin
	dd if=bootsec.bin of=bootsec.img bs=512 count=1
	dd if=/dev/zero of=bootsec.img skip=1 seek=1 bs=512 count=2879

bootsec.bin: bootsec.elf
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary bootsec.elf bootsec.bin

bootsec.elf: loader.o
	$(LD) loader.o -o bootsec.elf -e c -T loader.lds

loader.o: loader.s
	$(CC) -c loader.s

copy: boot.img

clean: 
	rm -f loader.o bootsec.elf bootsec.bin a.out boot.img
	rm -f *~

distclean: clean
	rm -f bootsec.img

release: clean
	mv bootsec.img berkeliumos.img
