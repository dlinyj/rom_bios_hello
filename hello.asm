%ifdef COM_FILE
    BITS 16
    ORG 100h
%else
    BITS 16
    ORG 0
%endif

%ifndef COM_FILE
    ; ROM BIOS header
    db 0x55, 0xAA        ; signature
    db rom_size/512      ; size in 512 byte blocks
%endif
start:
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
%ifdef COM_FILE
    ; COM exit
    mov ax, 0x4c00
    int 21h
%else
    ; ROM return
    retf
%endif

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

hello_world_msg db `Hello World.\r\n\0`

    cur_style db 0x07 ; grey on black = default
%ifndef COM_FILE
    ; ROM size calculation
    rom_end equ $-$$
    rom_size equ (((rom_end-1)/512)+1)*512
    ; Padding to full size
    times rom_size-($-$$)-1 db 0
    db 0    ; Place for checksum
%endif


