section .multiboot_header
header_start:
	dd 0xe85250d6 ; magic number  i dont knwo what that is
	dd 0 ; boot into protected mode (for grub to figure out)
	dd header_end - header_start ; header length

	; checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))
	
	; ending tag
	dw 0 ; type
	dw 0 ; flags
	dd 8 ; size
header_end:


