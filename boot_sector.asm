;;; -*- mode: nasm; nasm-basic-offset: 3; tab-width: 3; indent-tabs-mode: t; -*-
[bits 16]
[org 0x7c00]
	stack_base equ 0x7FFF
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
	mov di, first_slot
	call format_hex
	mov byte [first_slot + 4], 0
	call print_string

	mov ax, 0x0240                    ; BIOS read sector function, 64 sectors
	; mov dl, [boot_device] ; Seeing as we haven't clobbered `DL` yet, ; Drive number
	; let's not bother doing this read.
	mov cx, 2                         ; Cylinder number 0, sector number 1
	xor dh, dh                        ; Track number 0
	mov bx, start_point + sector_size ; Address to read to
	int 0x13

	jmp $
;; Functions:
;;; Write content of register `AX` formatted as hexadecimal at address `DI`
;;; Requires 4 bytes of space at `DI`
format_hex:
	push ax     ; Preserve ax so it doesn't get mangled
	xchg al, ah ; We'll look at the high byte first
	call format_hex.write8
	xchg al, ah ; What about the low byte?
	call format_hex.write8
	pop ax      ; Restore the original value of ax
	ret         ; And we're done!
format_hex.write8:
	push ax     ; Preserve the low nybble temporarily
	shr al, 4   ; Get the high nybble
	call format_hex.write4
	pop ax      ; Let's retrieve the low nybble
	and al, 15  ; And isolate it from the high nybble
	call format_hex.write4
	ret
format_hex.write4:
	cmp al, 10  ; Is this digit alphabetic?
	sbb al, 69h ; Convert to ASCII value
	das
	stosb       ; Write the result to di
	ret

;;; Print null terminating string with address `SI`
print_string:
	push ax
	mov ah, 0x0e                 ; scrolling teletype BIOS routine
__print_string_loop:
	lodsb
	test al, al
	jz __print_string_exit
	int 0x10                     ; ISR 0x10 for screen BIOS routines
	jmp __print_string_loop
__print_string_exit:
	pop ax
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
