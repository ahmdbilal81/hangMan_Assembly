[org 0x100]
jmp start




GenRandNum:
    push bp
    mov bp,sp
    push cx
    push ax
    push dx

    MOV AH, 00h ; interrupts to get system time
    INT 1AH ; CX:DX now hold number of clock ticks since midnight
    mov ax, dx
    xor dx, dx
    mov cx, 10;
    div cx ; here dx contains the remainder of the division - from 0 to 9

    mov word[index],dx;

    pop cx;
    pop ax;
    pop dx;
    pop bp;
ret

clearScreen:
    push ax
    push es
    push di
    push cx
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov ax,0x0720
    mov cx,2000
    cli
    rep stosw
    pop cx
    pop di
    pop es
    pop ax
ret

intro:
    push es 
    push ax 
    push cx 
    push si 
    push di 
    
    mov  ax, 0xb800 
    mov  es, ax
    mov si,name
    mov di,3256
    mov cx,21
    mov ah,0x07
    
    cld 
    nextcharname:
        lodsb                 
        stosw                 
    loop nextcharname 


    mov si,welcome
    mov di,1016
    mov cx,18
    mov ah,0x04
    
    cld 
    nextcharwelcome:
        lodsb                 
        stosw                 
    loop nextcharwelcome

    pop  di 
    pop  si 
    pop  cx 
    pop  ax 
    pop  es 
ret

endmssg:
    pusha
    mov  ax, 0xb800 
    mov  es, ax
    mov ah,0x07
    mov si,mssg
    mov di,1960
    mov cx,27
    cld 
    nextcharthanks:
        lodsb                 
        stosw                 
    loop nextcharthanks
    popa
ret

PrintBorder:
    pusha
    mov ax,0xb800
    mov es,ax

    mov al,0x20
    mov ah,01100110b
    
    mov di,648
    mov cx,23
    rep stosw


    mov di,808
    borderVertical:
        mov [es:di],ax
        add di,160
        cmp di,3368
    jne borderVertical
    mov cx,42
    borderBottom:
        mov [es:di],ax
        mov [es:di+160],ax
        mov [es:di+320],ax
        add di,2
    loop borderBottom
    popa
ret

printInputline:
    pusha
    mov ax,0xb800
    mov es,ax
    mov ax,'_'

    mov ah,00110000b

    mov di,3490
    mov cx,4
    printInputbar:
        mov [es:di],ax
        add di,4
    loop printInputbar 

    popa
ret

homeScreenBackground:
    push ax
    push es
    push di
    push cx
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov ah,00110000b
    mov al,0x20
    mov cx,2000
    cli
    rep stosw
    pop cx
    pop di
    pop es
    pop ax
ret

clearKeyboard:
    pusha
    mov ax,0xb800
    mov es,ax
    mov di,188
    mov cx,60
    mov ah,00110000b
    mov al,0x20
    cld
    rep stosw
    popa
ret

PrintKeyBoard:
    pusha
    mov si,abc

    mov cx,26
    mov ax,0xb800
    mov es,ax
    mov di,188
    mov ah,00111110b

    printABCLoop
        mov al,[si]
        cmp al,0
        je skipABC
        mov [es:di],ax
        skipABC:
        add di,4
        inc si
    loop printABCLoop
    popa
ret

removeFromKeyboard:
    push bp
    mov bp,sp
    pusha

    mov ax,[bp+4]

    mov cx,26
    mov si,abc
    searchChar:
        mov bl,[si]
        cmp bl,al
        je remove
        inc si
    loop searchChar
    jmp exitFromremoveFromKeyboard
    remove:
        mov byte[si],0
    exitFromremoveFromKeyboard:
    popa
    pop bp
ret 2

printFoundedInput:
    push bp
    mov bp,sp
    pusha

    mov si,[bp+4]
    mov cx,[bp+6]
    mov di,3346
    cmp cx,0
    je printLastWord
    goToposition:
        sub di,4
    loop goToposition
    printLastWord:
    mov ax,0xb800
    mov es,ax
    mov ah,00110100b
    mov al,[si]
    mov [es:di],ax

    popa
    pop bp
ret 2


head:
    pusha
	mov ax, 0xb800
	mov es, ax
	
	mov ah, 0x44
	mov al, ' '
	
	mov di, 1008
	
	mov cx, 5
    .l1:
	mov [es:di], ax
	add di, 2
	loop .l1
	
	add di, 150
	mov [es:di], ax
	add  di, 160
	mov [es:di], ax
	mov cx, 5
    .l2:
	mov [es:di], ax
	add di, 2
	loop .l2
	sub di, 162
	mov [es:di], ax
	
	
	popa
ret

body:
    pusha
	mov ax, 0xb800
	mov es, ax
	
	mov ah, 0x44
	mov al, ' '
	
	mov di, 1492
	
	mov cx, 6
    .l1:
	mov [es:di], ax
	add di, 160
	loop .l1
	
	popa
ret
	
printarms:
	pusha
	mov ax, 0xb800
	mov es, ax
	
	mov ah, 0x44
	mov al, ' '
	
	mov di, 1652
	
	mov cx, 4
    .l1:
	mov [es:di], ax
	add di, 164
	loop .l1
	
	mov di, 1652
	
	mov cx, 4
    .l2:
	mov [es:di], ax
	add di, 156
	loop .l2
	
	popa
ret
	
printlegs:
	pusha
	mov ax, 0xb800
	mov es, ax
	
	mov ah, 0x44
	mov al, ' '
	
	mov di, 2292
	
	mov cx, 6
    .l1:
	mov [es:di], ax
	add di, 162
	loop .l1
	
	mov di, 2292
	
	mov cx, 6
    .l2:
	mov [es:di], ax
	add di, 158
	loop .l2
	
	popa
ret

drawMan:
    pusha
    mov cx,[part]
    cmp cx,1
    je first
    cmp cx,2
    je second
    cmp cx,3
    je third
    cmp cx,4
    je forth




    first:
        call head
        jmp exitFromDrawMan
    second:
        call body
        jmp exitFromDrawMan
    third:
        call printarms
        jmp exitFromDrawMan
    forth:
        call printlegs
        call diedprint
    exitFromDrawMan:
    inc word[part]
    popa
ret

diedprint:
    pusha
    mov  ax, 0xb800 
    mov  es, ax
    mov si,died
    mov di,3110
    mov cx,4
    mov ah,1011110b
    
    cld 
    nextchardied:
        lodsb                 
        stosw                 
    loop nextchardied 
    popa
ret


gameLoop:
    pusha
    call GenRandNum
    mov si,dictionary
    mov cx,[index]
   
    
    cmp cx,0
    je skipAddingIndex

    pointSItoIndexInArray:
        add si,4
    loop pointSItoIndexInArray
    skipAddingIndex:
    mov bx,si
    ;printing the selected word from dict.
    mov  ax,0xb800 
    mov  es,ax
    mov di,3810
    mov cx,4
    mov ah,00110100b
    cld 
    nextchar:
        lodsb                 
        stosw  
        add di,2               
    loop nextchar 

    
    
    
    ;now take input and compare with bx
    takeInputLoop:
        mov ah,0
        int 0x16

        mov si,bx
        mov cx,4

        checkIncompleteWord:
            cmp al,[si]
            je inputFound
            inc si
        loop checkIncompleteWord
        jmp notFound
        inputFound:
            push cx ; index of word to print
            push si
            call printFoundedInput
            inc word[CorrectGuess]
            cmp word[CorrectGuess],4
            je exitInputLoop
            jmp skipHang
        notFound:
            call drawMan
            dec word[lives]
            cmp word[lives],0
            je exitInputLoop
        skipHang:
        mov ah,0
        push ax
        call removeFromKeyboard
        call clearKeyboard
        call PrintKeyBoard
    jmp takeInputLoop
    exitInputLoop:
    ;last pseudo intput just to show the screen at the end
    mov ah,0
    int 0x16
    call clearScreen
    call endmssg
   
    popa
ret

start:
    call clearScreen
    call intro
    mov ah,0
    int 0x16
    call homeScreenBackground
    call PrintKeyBoard
    call PrintBorder
    call printInputline
    call gameLoop
  
    
mov ax,0x4c00
int 0x21



; section .data
dictionary:db 'hang','quiz','yoga','jinx','haze','jade','kale','hens','myth','four'
index:dw 0 
abc: db 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k' ,'l' ,'m' ,'n' ,'o' ,'p' ,'q' ,'r' ,'s' ,'t' ,'u' ,'v', 'w', 'x', 'y', 'z'
CorrectGuess:dw 0
lives:dw 4
part:dw 1
name:db 'Bilal Ahmad (BDS-3B) ';21
welcome:db 'Welcome to HangMan';18 
mssg:db 'Thanks for playing the game' 
died:db 'died'
