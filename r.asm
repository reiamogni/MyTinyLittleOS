xor ax , ax
mov ss , ax
mov sp , 0x7c00
mov es ,ax
mov ds , ax
mov si , 0x7c00
mov di , 0x600
mov cx , 0x200
cld
rep movsb 


push ax
push 0x61c
retf

mov bp , 0x7be

push 0x0000
push 0x0000
push 0x0000
push 0x0800
push 0x0000
push 0x7c00
push 0x0001
push 0x0010

mov ah , 0x42
mov dl , [bp]
mov si , sp
int 0x13

xor ax,ax
push ax
push 0x7c00
retf

