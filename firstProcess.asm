org 0x7c00

mov ah , 0
mov al , 2
int 0x10 ; 			Video mode setzen

xor ax , ax  
mov es , ax
mov cx , 14
mov bp , text
mov dx , 0x0101
call printText




mainloop:	; 0x7c16

call clearLastLine
xor ax,ax
mov es , ax
mov bp , fragezeichen
mov cx , 1
mov dx , 0x1800
call printText


mov ah , 0; Tastaturabfrage 
int 0x16

mov ah , 2
mov bh , 0
mov dx , 0x1803
int 0x10

mov ah , 0x0a
mov cx , 1
int 0x10



; ab hier auswertung der eingabe
cmp al , 0x68	;h 0x7c3a
jnz keyTest_1
call keyPressed_h

keyTest_1: cmp al , 0x6d	;m
jnz keyTestEnd
call keyPressed_m


keyTestEnd: jmp mainloop



text db 'jetzt gehts los'
fragezeichen: db '?'
leerzeichen: db ' '






keyPressed_h:	


mov al , byte [keyPressed_hSegment]
mov ah , 0
sal ax , 12
mov es , ax
mov bp , [keyPressed_hAddress]
mov dx , 0

mov bx , 24
keyPressed_hLoop2:
mov dl , 0
push bx
push bp
push dx
push es
mov ax , es
call printWord
pop es
pop dx
pop bp

add dx , 5
mov ax , bp
push bp
push dx
push es
call printWord
pop es
pop dx
pop bp

mov dl , 0x10

mov cx , 8
keyPressed_hLoop1: push es 
push bp
push cx
push dx
mov al , [es:bp]
call printHex
push dx
pop dx 
add dx , 1
mov bp , leerzeichen
mov cx , 1
xor ax , ax
mov es , ax 
mov cx , 1
call printText
pop dx
pop cx
pop bp
pop es
add dx , 3
inc bp
dec cx
jnz keyPressed_hLoop1

pop bx
inc dh
dec bx 
jnz keyPressed_hLoop2

ret
keyPressed_hSegment db 0
keyPressed_hAddress db 0,0



keyPressed_m: ;0x7cbf
call clearLastLine
xor ax , ax
mov es ,ax
mov bp , keyPressed_mText
mov cx , 9
mov dx , 0x1800
call printText

call readHexNumber
push ax
push bx
mov ah , 0x3
mov bh , 0
int 0x10
inc dx
mov ah , 0x2
int 0x10
pop bx
pop ax
mov ah , 0xa
mov cx , 1
int 0x10
mov [keyPressed_hSegment] , bl



call readHexNumber
push ax
push bx
mov ah , 0x3
mov bh , 0
int 0x10
inc dx
mov ah , 0x2
int 0x10
pop bx
pop ax
mov ah , 0xa
mov cx , 1
int 0x10
mov dl , bl
sal dl , 4

push dx 
call readHexNumber
push ax
push bx
mov ah , 0x3
mov bh , 0
int 0x10
inc dx
mov ah , 0x2
int 0x10
pop bx
pop ax
mov ah , 0xa
mov cx , 1
int 0x10
pop dx
add bl , dl
mov bp , keyPressed_hAddress
mov [bp + 1] , byte bl


call readHexNumber
push ax
push bx
mov ah , 0x3
mov bh , 0
int 0x10
inc dx
mov ah , 0x2
int 0x10
pop bx
pop ax
mov ah , 0xa
mov cx , 1
int 0x10
mov dl , bl
sal dl , 4

push dx
call readHexNumber
push ax
push bx
mov ah , 0x3
mov bh , 0
int 0x10
inc dx
mov ah , 0x2
int 0x10
pop bx
pop ax
mov ah , 0xa
mov cx , 1
int 0x10
pop dx
add dl , bl 
mov bp , keyPressed_hAddress
mov [bp] , byte dl




ret

keyPressed_mText db 'Speicher:'
keyPressed_mInput db'     '




printHex: ; eingabe al als hex auszugebender Wert dx zeile spalte   

push ax		; highbyte ausgeben
sar ax , 4
and al , 0x0f	
mov di , printHexAusgabe
mov ah , 0
add di , ax
mov al , [di]
mov ah , 2
mov bh , 0
int 0x10
mov ah , 0x0a
mov cx , 1
int 0x10
pop ax

inc dl

and al , 0x0f	;lowbyte ausgeben
mov di , printHexAusgabe
mov ah , 0
add di , ax
mov al , [di]
mov ah , 2
mov bh , 0
int 0x10
mov ah , 0x0a
mov cx , 1
int 0x10

ret

printHexAusgabe: db '0123456789ABCDEF'



printWord: ; eingabe ax dx zeile spalte
push ax
push dx
mov al , ah
call printHex
pop dx
pop ax
add dx , 2
call printHex
ret


printText:	; es bp enthält speicheraddresse des textes cx die laenge dx zeile spalte 0x7c7c
xor ax , ax  
mov ax , 0x1301
mov bx , 0x0007
int 0x10
ret


clearLastLine:
mov ah , 2
mov bh , 0
mov dx , 0x1800
int 0x10

mov ax , 0x0a20
mov cx , 80
int 0x10
ret




readHexNumber: ; bl gibt den gelesenen Wert zurück al enthält gedrückte taste 0x7d54
readHexNumberLoop2: mov ah , 0
int 0x16

mov di , readHexNumberInput
push ax
xor ax,ax
mov es , ax
pop ax

mov bl , 0x0
readHexNumberLoop1: cmp al , byte [es:di]
jnz readHexNumberNotEqual

ret
  
readHexNumberNotEqual:
inc di
inc bl
cmp bl , 0x10
jnz readHexNumberLoop1
jmp readHexNumberLoop2
readHexNumberInput db'0123456789abcdef'