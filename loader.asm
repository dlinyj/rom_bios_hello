bits 16
    db 0x55, 0xAA ; signature
    db 32768/512; initialization size in 512 byte blocks

    jmp _init
_init:
    cld
    mov si, 512
    xor di,di ;kuda
    mov cx,0x8000
    mov es,cx
    mov ax,cs
    mov ds,ax
    mov cx, 32768-512

    rep
    movsw

; inicjalizacja steka (0000:fffe) i segmentu dannyh

;    mov ax,0xfffe
;    mov sp,ax
;    xor ax,ax
;    mov ss,ax

;    mov ax,0x8000
;    mov ds,ax

;    jmp 0x8000:_start
    jmp 0x8000:0000
