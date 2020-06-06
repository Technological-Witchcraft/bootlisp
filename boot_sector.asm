;;; -*- mode: nasm; -*-
[bits 16]
[org 0x7c00]
        stack_base equ 0x7FFFF
        boot_device equ 0x500
        first_slot equ boot_device + 2
        second_slot equ first_slot + 5

        mov ebp, stack_base     ; Set up the stack
        mov esp, ebp
        mov [boot_device], dl   ; Save boot device

        mov bx, msg
        call print_string
        mov bx, first_slot
        mov ax, 0xbeef
        call format_hex
        mov byte [first_slot + 4], 0
        call print_string

        jmp $
;; Functions:
;;; Write content of register `AX` formatted as hexadecimal at address `BX`
;;; Requires 4 bytes of space at `BX`
format_hex:
        pusha
;; This is essentially an unrolled loop.
;; We can make it into a loop to save space if we must.
%macro __format_hex_digit 1
        mov dx, ax
        and dx, 0xf << (%1 * 4)
        shr dx, (%1 * 4)
        cmp dx, 9
        jnc %%letter
        add dx, '0'
        jmp %%end
        %%letter:
        add dx, 'a' - 10
        %%end:
        mov [bx], dl
%endmacro
        __format_hex_digit 3
        add bx, 1
        __format_hex_digit 2
        add bx, 1
        __format_hex_digit 1
        add bx, 1
        __format_hex_digit 0
        popa
        ret
;;; Print null terminating string with address `BX`
print_string:
        pusha
        mov ah, 0x0e            ; scrolling teletype BIOS routine
__print_string_loop:
        mov al, [bx]
        cmp al, 0
        je __print_string_exit
        int 0x10                ; ISR 0x10 for screen BIOS routines
        add bx, 1
        jmp __print_string_loop
__print_string_exit:
        popa
        ret
;; Data:
msg: db 'Hello, world!', 0
        times 510-($-$$) db 0   ; pad to end of sector
        dw 0xaa55               ; BIOS magic number

;; # Lower Memory
;; 
;; 00000000-000003FF
;;     Length: 1 KiB
;;     Type: Hardware
;;     Description: IVT
;; 
;; 00000400-000004FF
;;     Length: 256 bytes
;;     Type: Reserved
;;     Description: BIOS data area
;; 
;; 00000500-0007FFFF
;;     Length: 510 KiB
;;     Type: Usable
;;     Description: Usable
;; 
;; 00080000-0009FFFF
;;     Length: 128 KiB
;;     Type: Reserved
;;     Description: BIOS Data Area
;; 
;; # Upper Memory
;; 
;; 000A0000-000BFFFF
;;     Length: 128 KiB
;;     Type: Hardware
;;     Description: Video Memory
;; 
;; 000C0000-000FFFFF
;;     Length: 255 KiB
;;     Type: Reserved
;;     Description: BIOS Data Area
