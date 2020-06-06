;;; -*- mode: nasm; nasm-basic-offset: 3; tab-width: 3; indent-tabs-mode: t; -*-
[bits 16]
[org 0x7c00]
	stack_base equ 0x7FFFF
	boot_device equ 0x500
	first_slot equ boot_device + 2
	second_slot equ first_slot + 5
	start_point equ 0x7c00
	sector_size equ 512

	mov bp, stack_base     ; Set up the stack
	mov sp, bp
	mov [boot_device], dl   ; Save boot device

	mov si, msg
	call print_string
	mov si, first_slot
	mov ax, 0xbeef
	call format_hex
	mov byte [first_slot + 4], 0
	call print_string

	mov ah, 0x02                 ; BIOS read sector function
	; mov dl, [boot_device] ; Seeing as we haven't clobbered `DL` yet, ; Drive number
	; let's not bother doing this read.
	mov ch, 0                         ; Cylinder number
	mov dh, 0                         ; Track number
	mov cl, 2                         ; Sector number (starts at 1)
	mov al, 64                        ; Number of sectors
	mov bx, start_point + sector_size ; Address to read to
	int 0x13

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
	mov [si], dl
%endmacro
	__format_hex_digit 3
	inc si
	__format_hex_digit 2
	inc si
	__format_hex_digit 1
	inc si
	__format_hex_digit 0
	popa
	ret
;;; Print null terminating string with address `SI`
print_string:
	pusha
	mov ah, 0x0e                 ; scrolling teletype BIOS routine
__print_string_loop:
	lodsb
	test al, al
	jz __print_string_exit
	int 0x10                     ; ISR 0x10 for screen BIOS routines
	jmp __print_string_loop
__print_string_exit:
	popa
	ret

;; Data:
msg: db 'Hello, world!', 0
	times 510-($-$$) db 0        ; pad to end of sector
	dw 0xaa55                    ; BIOS magic number

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
