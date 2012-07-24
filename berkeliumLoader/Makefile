# BerkeLiumOS
#
# BootLoader Makefile

CC=gcc
LD=ld
LDFILE=stage1.lds
OBJCOPY=objcopy

all: bootsec.img

bootsec.img: bootsec.bin loader.bin
	dd if=bootsec.bin of=bootsec.img bs=512 count=1
	dd if=/dev/zero of=bootsec.img skip=1 seek=1 bs=512 count=2879

loader.bin: loader.elf
	$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary loader.elf loader.bin

bootsec.bin: bootsec.elf
	$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary bootsec.elf bootsec.bin

loader.elf: stage2.o
	$(LD) stage2.o -o loader.elf -e c -T stage2.lds

bootsec.elf: stage1.o
	$(LD) stage1.o -o bootsec.elf -e c -T stage1.lds

stage1.o: stage1.s
	$(CC) -c stage1.s

stage2.o: stage2.s
	$(CC) -c stage2.s

copy: boot.img

clean:
	rm -f *.o *.bin *.elf
	rm -f a.out boot.img
	rm -f *~

distclean: clean
	rm -f bootsec.img

release: clean
	mv bootsec.img berkeliumos.img
