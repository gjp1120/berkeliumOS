# BerkeLiumOS BootLoader
# Stage2

.code16
.text
mov $0xb800, %ax
mov %ax, %gs
mov $0xf, %ah
mov $'L', %al
mov %ax, %gs:((80*0+39)*2)
jmp .
