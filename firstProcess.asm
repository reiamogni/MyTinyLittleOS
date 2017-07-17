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
cmp al , 0x68			;h
jnz keyTest_1
call keyPressed_h

keyTest_1: cmp al , 0x6d	;m
jnz keyTest_2
call keyPressed_m

keyTest_2: cmp al , 0x66	;f
jnz  keyTest_3
call keyPressed_f

keyTest_3: cmp al , 0x77	; w
jnz keyTestEnd
call keyPressed_w


keyTestEnd: jmp mainloop



text db 'jetzt          '
fragezeichen: db '?'
leerzeichen: db ' '






keyPressed_h:	

;***************************************** ab hier wird hex code ausgegeben ********************************
xor ax , ax 
mov ds , ax
mov es , ax
mov al , byte [es : keyPressed_hSegment]
mov ah , 0
sal ax , 12
mov es , ax
mov bp , [ds : keyPressed_hAddress]
mov dx , 0

mov bx , 24		; Zeilenanzahl
keyPressed_hLoop2:
mov dl , 0
push bx
push bp
push dx
push es
mov ax , es
call printWord		;ausgabe segment
pop es
pop dx
pop bp

add dx , 5
mov ax , bp
push bp
push dx
push es
call printWord		;ausgabe adresse
pop es
pop dx
pop bp

mov dl , 0x10

mov cx , 8		;anzahl der werte die ausgegeben werden sollen
keyPressed_hLoop1: push es 
push bp
push cx
push dx
mov al , [es:bp]
push ax
call printHex		;ausgabe der hex werte

add dx , 1
mov bp , leerzeichen
mov cx , 1
xor ax , ax
mov es , ax 
mov cx , 1
call printText
pop ax
call printChar

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
;****************************************** ende ausgabe hexcode *****************************************

push ax
xor ax , ax 
mov es , ax 
pop ax
mov ax , [es : keyPressed_hAddress]
add ax , 0xc0
mov [es : keyPressed_hAddress] , ax
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
xor ax , ax 
mov es , ax
mov [es : keyPressed_hSegment] , bl



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
xor ax , ax
mov es , ax
inc bp
mov [es : bp] , byte bl


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
xor ax  , ax
mov es , ax
mov [es : bp] , byte dl




ret 

keyPressed_mText db 'Speicher:'
keyPressed_mInput db'     '





keyPressed_f:
xor ax , ax 
mov es , ax
mov al , [es :keyPressed_hSegment]
mov ah , 0 
sal ax , 12
mov ds , ax
xor ax , ax
mov si , [es : keyPressed_hAddress]
mov es , ax
mov bp , keyPressed_fText

keyPressed_fLoop1: 
push es
push bp
push ds
push si
call keyPressed_fSubTestString
pop si
pop ds
pop bp
pop es

cmp al , 1
jz  keyPressed_fBack

inc si
jnz keyPressed_fLoop1
mov ax , ds
add ax , 0x1000
mov ds , ax
cmp ax , 0x0
jnz keyPressed_fLoop1





keyPressed_fBack:
mov dx , 0x1805
mov ax , ds
call printWord
mov dx , 0x180b
mov ax , si
call printWord
mov ah , 0x0
int 0x16
ret




keyPressed_fSubTestString:	; es bp enthält string ds si enthält startadresse rückgabe al 1 für gleich al 0 für nicht gleich
mov al , byte [es : bp]
cmp al , 0
jz keyPressed_fSubTestStringEquals

cmp al , [ds:si]
jnz keyPressed_fSubTestStringNotEquals

inc bp
jnc keyPressed_fNoOverrun
push ax
mov ax , es
add ax , 0x1000
mov es , ax
pop ax

keyPressed_fNoOverrun:
inc si
jnc keyPressed_fNoOverrun2
push ax
mov ax , ds
add ax , 0x1000
mov ds , ax
pop ax

keyPressed_fNoOverrun2: jmp keyPressed_fSubTestString


keyPressed_fSubTestStringEquals:mov al , 1
ret

keyPressed_fSubTestStringNotEquals: mov al , 0
ret





keyPressed_w: 
call clearLastLine
xor ax , ax
mov es , ax
mov bp , keyPressed_fText
mov dx , 0x1803


keyPressed_wLoop: mov ah , 0; Tastaturabfrage 
int 0x16

mov ah , 2
mov bh , 0
int 0x10
inc dx

mov ah , 0x0a
mov cx , 1
int 0x10

cmp al , 13
jz keyPressed_wBack
mov [es:bp] , al
inc bp
jmp keyPressed_wLoop 

keyPressed_wBack:
inc bp
mov [es : bp] , byte 0
ret


;***************************************unterprogramme fuer zeilenausgabe etc **************************************
printHex: ; eingabe al als hex auszugebender Wert dx zeile spalte   

push ax		; highbyte ausgeben
sar ax , 4
and al , 0x0f	
mov di , printHexAusgabe 
mov ah , 0
add di , ax
xor ax , ax
mov es , ax
mov al , [es:di]
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
xor ax , ax
mov es , ax
mov al , [es : di]
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



printChar: ; al enthält hexcode dx enthält position
cmp al , 0x20
jnc printCharLoop
mov al , 0x2e
printCharLoop:
push ax
mov ah , 0x03
mov bh , 0
int 0x10
add dl , 30
dec ah
int 0x10

pop ax
mov ah , 0x0a
mov cx , 1
int 0x10
ret



keyPressed_fText db 'RSDT'
db 0