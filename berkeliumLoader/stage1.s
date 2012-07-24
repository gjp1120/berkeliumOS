#BerkeliumOS BootLoader
#Stage1
#***Author: gjp1120<gjp1120@gmail.com>
.set BaseOfStack,             0x7c00  #$ = .
.set BaseOfLoader,            0x9000  
.set OffsetOfLoader,          0x0100
.set RootDirSectors,          14      #$ = (BPB_RootEntCnt*32)/BPB_BytesPerSec
.set StartSecOfDir,           19      #$ = BPB_NumFATs*BPB_FATSz16+BPB_RsvdSecCnt+RootDirSectors
.set StartSecOfFAT1,          1       #$ = (BPB_RsvdSecCnt - 1) + 1
.set DeltaSecNo,              17      #$ = RootDirSectors - 2

.code16
.text
BS_jmpBoot:                                            #jump to BootLABELL: init_loader
jmp init_loader
nop

#NAME                   TYPE    VAL
BS_OEMName:             .ascii  "berkelim"             #OSNAME(8byte)
BPB_BytesPerSec:        .2byte  512                    #Size of Sec
BPB_SecPerClus:         .byte   1                      #Sec(s) in 1 Clus
BPB_RsvdSecCnt:         .2byte  1                      
BPB_NumFATs:            .byte   1
BPB_RootEntCnt:         .2byte  224                    
BPB_TotSec16:           .2byte  2880                   #if you want write an 32bit val, let this val equ 0 
BPB_Media:              .byte   0xf0                   #Media Type, Floppy is 0xF0
BPB_FATSz16:            .2byte  9                     
BPB_SecPerTrk:          .2byte  18
BPB_NumHeads:           .2byte  2                      #
BPB_HiddenSec:          .4byte  0
BPB_TotSec32:           .4byte  0                      #if [BPB_TotSec16] == 0 , you should write an 32bit val in here

#These Vals different with FAT32
BS_DrvNum:              .byte   0                      #is Flp
BS_Reserved1:           .byte   0                      #Only Windows(R) NT use this
BS_BootSign:            .byte   0x29
BS_VolID:               .4byte  0x0
BS_VolLab:              .ascii  "berkeliumOS"          #Volume LABEL(11byte)
BS_FilSysType:          .ascii  "FAT12   "             #FileSystemType(8byte)


init_loader:
        #init sections
				mov %cs, %ax
				mov %ax, %ds                                   #ss = es = ds = cs
				mov %ax, %es
        mov %ax, %ss

        mov $BaseOfStack, %sp

        mov $BootMsgStr, %ax
        mov %ax, %bp
        mov $BootMsgLen, %cx
        call puts

        #reset floppy
        call reset

        #prepare to search LOADER.BIN
        movw $StartSecOfDir, (SectorNumber)
search_loader_begin:                 #Go on
        cmpw $0, (RootSizeForLoop)                      #if we already searched all RootDirItem
        jz loader_not_found                             #we can't found stage2 loader
        #if not
        decw (RootSizeForLoop)
        #perpare section [ES]
        mov $BaseOfLoader, %ax
        mov %ax, %es
        mov $OffsetOfLoader, %bx

        mov (SectorNumber), %ax                         #read 1 sector to memory
        mov $1, %cl
        call read

        mov $LoaderFileName, %si
        mov $OffsetOfLoader, %di
        cld

        mov $0x10, %dx

/* Search for "LOADER BIN", FAT12 save file name in 12 bytes, 8 bytes for
file name, 3 bytes for suffix, last 1 bytes for ’\20’. If file name is
less than 8 bytes, filled with ’\20’. So "LOADER.BIN" is saved as:
"LOADER BIN"(4f4c 4441 5245 2020 4942 204e).
*/
search_for_loader:
        cmp $0, %dx
        jz goto_next_sector_in_root
        dec %dx
        mov $11, %cx 
loader_cmp_filename: #Go ON
        cmp $0, %cx
        jz loader_found
        dec %cx
        lodsb                                           #%ds:(%si) => %al
        cmp %es:(%di), %al
        je  go_on_next_char
        jmp cmp_err_different

go_on_next_char:
        inc %di
        jmp loader_cmp_filename

cmp_err_different:
        and $0xffe0, %di
        add $0x20, %di
        mov $LoaderFileName, %si
        jmp search_for_loader

goto_next_sector_in_root:
        addw $1, (SectorNumber)
        jmp search_loader_begin


loader_not_found:
        mov $MessageNoLoader, %ax
        mov %ax, %bp
        mov $MessageNoLoaderLen, %cx
				call puts
				jmp .                                           #Loop forever

loader_found:
        mov $MessageLoaderReady, %ax
        mov %ax, %bp
        mov $MessageLoaderReadyLen, %cx
        call puts
        jmp .

# func puts
#     Put String BootMsgStr to Screen 
#			%bp => addr of String                                                    #  | | <- Low Addr
#     %cx => Len of String                                                     #  | | <- New Object will push to Here
puts:                                                                          #  |#| <- %ss:%sp
        push %es                                                               #  |#|
        mov %cs, %ax                                                           #  |#|
        mov %ax, %es                                                           #  |#|
				mov $0x1301, %ax        #%ah = 13h, %al = 01h                          #  |#|
				mov $0x0, %bh                                                          #  |#|
        mov $0x07, %bl          #00000111b = 7h                                #  |_| <- High Addr
				mov $0x0, %dh                                                          #
        mov $0, %dl                                                            #   
				int $0x10                                                              # Stack(8086)
        pop %es
				ret                                                         
# func read                                                         #                                 | val>>1 = 'cylinder num'
#     Read %cl sectors from %ax sector(Floppy) to %es:%bx(Memory)   # Sector number                   | val&1 = 'header num'
read:                                                               #--------------- = val ... rest =>|
        push %ebp                                      #save %epb   # BPB_SecPerTrk                   | rest+1 = 'start sector num'
        mov %esp, %ebp          #%ebp = %esp                        #
        sub $2, %esp            #%esp = %esp - 2       #Reserve 2 byte space on stack
        mov %cl, -2(%ebp)                              #use reserved 2 byte to save the %cl
        push %bx                                       #save %bx
        mov (BPB_SecPerTrk), %bl
        div %bl                                        #%bl is divider
        inc %ah                 #%ah = %ah + 1
        mov %ah, %cl                                   #Now, %cl include 'start sector number'
        mov %al, %dh
        and $1, %dh             #%dh = %dh & 1         #Now, 'header number' is in %dh 
        shr $1, %al             #%al = %al >> 1
        mov %al, %ch                                   #Now, %ch is ready, %ch is 'cylinder number'
        pop %bx
        mov (BS_DrvNum), %dl
# func direct_read
#     Go on prev func(read), use BIOS int $0x13 read data from Floppy
#     Don't direct use this func
direct_read: #(Go on)
        mov $0x2,%ah                                   # %ah = 2, use READ
        mov -2(%ebp), %al                              #Now, %al is 'read sectors count'
        int $0x13                                      #Call BIOS
        jc direct_read                                 #if CF(FLAG) == 1, mean 'read error', retry...
        add $2, %esp
        pop %ebp
        ret
# func reset(NO ANY ARG)
#     Reset Floppy(BS_DrvNum)
reset:
        xor %ah, %ah             #%ah = 0
        mov (BS_DrvNum), %dl
        int $0x13
        ret
#String Table
BootMsgStr:         .ascii "Hello, From berkeliumOS(Jul 18, 2012)!\n\rself loop..."
BootMsgLen = (. - BootMsgStr)
LoaderFileName:     .asciz "LOADER  BIN" #FAT filename is 8+3 format, end with an 0, so must use '.asciz'
MessageNoLoader:    .ascii "NO LOADER\n\r"
MessageNoLoaderLen = (. - MessageNoLoader)
MessageLoaderReady: .ascii "Loaded in\n\r"
MessageLoaderReadyLen = (. - MessageLoaderReady)
#Valname                  TYPE    Val
RootSizeForLoop:          .2byte  RootDirSectors
SectorNumber:             .2byte  0
Odd:                      .byte   0
LineNum:                  .byte   0
.org 510
.word 0xaa55
