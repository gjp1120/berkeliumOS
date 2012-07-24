#BerkeliumOS BootLoader
#***Author: gjp1120<gjp1120@gmail.com>

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
				mov %cs,%ax
				mov %ax,%ds
				mov %ax,%es
				call Dispstr
				jmp .
Dispstr:
				mov $BootMsgStr,%ax
				mov %ax,%bp
				mov $BootMsgLen,%cx
				mov $0x1301,%ax
				mov $0x0,%bh
        mov $0x07,%bl  #00000111b = 7h
				mov $0,%dl
				int $0x10
				ret
BootMsgStr:.ascii "Hello, From berkeliumOS(Jul 18, 2012)!\n\rself loop..."
BootMsgLen = (. - BootMsgStr)
.org 510
.word 0xaa55
