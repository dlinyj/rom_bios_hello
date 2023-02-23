org 0
rom_size_multiple_of equ 512
bits 16
    db 0x55, 0xAA ; signature
    db rom_size/512; initialization size in 512 byte blocks

    jmp _init

    db 0x00     ; miejsce na sumê kontroln±, offset 0x0006

_init:
    cld
    xor si,si ;otkuda
;   mov si, start
    nop
    xor di,di ;kuda
    mov cx,0x8000
    mov es,cx
    mov ax,cs
    mov ds,ax
    rep
    movsw

; inicjalizacja steka (0000:fffe) i segmentu dannyh

    mov ax,0xfffe
    mov sp,ax
    xor ax,ax
    mov ss,ax

    mov ax,0x8000
    mov ds,ax

    jmp 0x8000:_start
;   jmp 0x8000:0000

_start:
    push CS
    pop DS
;    mov [sp_orig], SP
    call cls

hello:
    push AX
    mov AX, hello_world_msg
    call puts
    pop AX
    call getc

cls:
    ; Clear screen
    mov AH, 06h
    mov AL, 0
    mov BH, 07h
    mov CH, 0
    mov CL, 0
    mov DH, 24
    mov DL, 79
    int 10h

    ; Move cursor to 0, 0
    mov DL, 0
    mov DH, 0
    mov BH, 0 ; page number
    mov AH, 02h ; set cursor position
    int 10h
    ret

puts:
    push AX
    push BX
    mov BX, AX
puts_loop:
    mov AL, [BX]
    cmp AL, 0
    jz end_puts
    call putc 
    inc BX
    jmp puts_loop
end_puts:
    pop BX
    pop AX
    ret

putc: 
    pusha
    cmp AL, `\n`
    jz putc_nl
    cmp AL, `\r`
    jz putc_nl
    jmp putc_print_char

putc_nl:
    mov AH, 03h ; get cursor position
    mov BH, 0 ; page number
    int 10h
    mov DL, 79
    jmp nl_jump

putc_print_char:
    mov AH, 09h
    mov AL, AL ; character
    mov BL, [cur_style]
    mov BH, 0 ; page number
    mov CX, 1 ; count
    int 10h
    
    mov AH, 03h ; get cursor position
    mov BH, 0 ; page number
    int 10h
nl_jump:
    inc DL ; column
    cmp DL, 79
    jle putc_set_cursor
    mov DL, 0
    inc DH

    cmp DH, 24
    jle putc_set_cursor

    ; Scroll one line up
    mov AH, 06h
    mov AL, 1
    mov BH, 07h
    mov CH, 0
    mov CL, 0
    mov DH, 24
    mov DL, 79
    int 10h

    mov AH, 03h ; get cursor position
    mov BH, 0 ; page number
    mov DL, 0

putc_set_cursor:
    mov AH, 02h ; set cursor position
    int 10h
    popa
    ret

getc: ; changes AH...
    mov AH, 0
    int 0x16 
    ret

hello_world_msg db `Hello World.\0`

    cur_style db 0x07 ; grey on black = default
;    sp_orig dw 0x0000 ; original stack pointer for returning in case of an error
    ; ROM padding, checksum needs to be added separately
    ; --------------------------------------------------

    db 0 ; reserve at least one byte for checksum
rom_end equ $-$$
rom_size equ (((rom_end-1)/rom_size_multiple_of)+1)*rom_size_multiple_of
;    times rom_size - rom_end db 0 ; padding


