mov bp , di

;verschieben nach 0x600 */
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

;/*sprung*/
push ax
push 0x61e
retf

;/*tastaturabfrage*/
mov ah , 0
int 0x16

cmp al , 0x20
jz loop_non_windows


;/*laden des windows bootloaders von sektor 0x800 nach 0x7c00*/
loop_windows:
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


;leertaste gedrückt 0x64b
loop_non_windows:	

push 0x0000
push 0x0000
push 0x0000
push 0x0001 ; startblock
push 0x0000
push 0x7c00
push 0x000a ; anzahl der blocks
push 0x0010

mov ah , 0x42
mov si , sp
int 0x13

xor ax , ax
push ax
push 0x7c00
retf







; ***********************************ab hier steinbruch
mov ah , 0
mov al , 2
int 0x10 ; 			Video mode setzen

xor ax , ax  
mov es , ax
mov ax , 0x1301
mov bx , 0x0007
mov cx , 10
mov dx , 0x0101
mov bp , 0x69e
int 0x10

mov bx , 0x0;			0x666
mov cx , 0x0; 			speichert hohen 4 bit 

loop2: 									
	mov ax , cx
	sal ax , 12
	mov es , ax
	 
	mov di , bx
	mov al , [es : di]
	cmp al , 0x52 ;		hier erster buchstabe
	jnz hupf
	call meldung
	hupf: inc bx
	jnz loop2
	inc cx
	cmp cx , 0x10
	jnz loop2	

loopi: jmp loopi


mov ax , 0x1301
mov cx , 4 
mov bp , 0x699
mov dx , 0x0101
mov bl , 7
int 0x10

schluss: jmp schluss
vorbei: db 'ausis'
starttext: db 'los gehts'



meldung: 

mov al , [es:di + 0]
cmp al , 0x52
jnz zuruck
mov al , [es:di + 1]
cmp al , 0x53
jnz zuruck

mov al , [es:di + 2]
cmp al , 0x44
jnz zuruck

mov al , [es:di + 3]
cmp al , 0x54
jnz zuruck

push bx
push cx
mov ax , 0x1301
mov cx , 01024
mov bp , di
mov dx , 0x0101
mov bx , 0x0007
int 0x10
pop cx 
pop bx

looping:jmp looping


mov ah , 0x13
mov cx , 4
mov bh , 0
mov al , 1
mov bl , 7
mov bp , di
mov dx , 0x0a0a
int 0x10

mov ah , 0
int 0x16 

mov ax , 0x0002 
int 0x10

zuruck: ret

