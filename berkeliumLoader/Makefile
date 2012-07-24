# BerkeLiumOS
#
# BootLoader Makefile

CC=gcc
LD=ld
LDFILE=stage1.lds
OBJCOPY=objcopy

all: bootsec.img

bootsec.img: bootsec.bin loader.bin
	@echo 'making bootsec.img'
	@dd if=bootsec.bin of=bootsec.img bs=512 count=1 2> /dev/null
	@dd if=/dev/zero of=bootsec.img skip=1 seek=1 bs=512 count=2879 2>/dev/null

loader.bin: loader.elf
	@echo 'convert loader(ELF) to BIN'
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary loader.elf loader.bin

bootsec.bin: bootsec.elf
	@echo 'convet bootsec(ELF) to BIN'
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary bootsec.elf bootsec.bin

loader.elf: stage2.o
	@echo 'linking stage2 ...'
	@$(LD) stage2.o -o loader.elf -e c -T stage2.lds

bootsec.elf: stage1.o
	@echo 'linking stage1 ...'
	@$(LD) stage1.o -o bootsec.elf -e c -T stage1.lds

stage1.o: stage1.s
	@echo 'compile stage1 ...'
	@$(CC) -c stage1.s

stage2.o: stage2.s
	@echo 'compile stage2 ...'
	@$(CC) -c stage2.s

copy: bootsec.img
	@echo 'copying system loader ...'
	@sudo mount -o loop ./bootsec.img /media/fp/
	@sudo cp ./loader.bin /media/fp
	@sudo umount /media/fp/

clean:
	@echo 'cleaning ...'
	@rm -f *.o *.bin *.elf
	@rm -f a.out boot.img
	@rm -f *~

distclean: clean
	@echo 'removing .img ...'
	@rm -f bootsec.img

release: all clean
	@echo 'gen finally system image ...'
	@mv bootsec.img berkeliumos.img
