global start

section .text
bits 32
start:

	; point the first entry of the level 4 page to the page table to the first entry in the 
	; p3 table
	mov eax, p3_table ; copy the contents of p3_table into register eax
	or eax, 0b11 ; eax is a register
	mov dword [p4_table + 0], eax

	; point each page table level two entry to a page
	mov ecx, 0 ; counter variable ; ecx is the counter register

	.map_p2_table:
		mov eax, 0x200000 ; 2MiB
		; since the page size is 2MiB , the counter (memory location) is incremented(multiplied by 0x200000 or 2MiB)
		mul ecx ; mul is multiplication 
		or eax, 0b10000011
		mov [p2_table + ecx * 8], eax
		
		inc ecx ; incremented by one
		cmp ecx, 512 ; compare
		jne .map_p2_table ; jump to 
		
	; move page table address to cr3
	mov eax, p4_table
	mov cr3, eax ; cr3 is a control register and can only get memory address from another register and not from a label

	; enable PAE 
	mov eax, cr4
	or eax, 1 << 5 ; 1 << 5 is a left shift in bit position, in this case the bit 1 is moved by 5 to the left giving a denary of 2^6 = 64 instead of 1
	mov cr4, eax
	
	; long mode bit 
	mov ecx, 0xc0000080
	rdmsr
	or eax, 1 << 8
	wrmsr
	; rdmsr and wmsr are read and write to model specific register 
	
	; enable paging
	mov eax, cr0
	or eax, 1 << 31
	or eax, 1 << 16
	mov cr0, eax
	
	

	; will print after the code above runs 
	mov word [0xb8000], 0x0248 ; H
	mov word [0xb8002], 0x0265 ; e
	mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ;
    mov word [0xb800e], 0x0277 ; w
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
	hlt

section .bss ; block started by symbol
align 4096

p4_table:
	resb 4096 ; reserve bytes 4096
p3_table:
	resb 4069
p2_table:
	resb 4096

section .rodata ; read only data
gdt64:
	dq 0 ; quad word, 64 bit value 

	.code: equ $ - gdt64
		dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)

	.data: equ $ - gdt64
		dq (1<<44) | (1<<47) | (1<<41)

	.pointer: 
		dw .pointer - gdt64 - 1
		dq gdt64

; pass the value of pointer 
lgdt [gdt64.pointer]

; update selectors
mov ax, gdt64.data
mov ss, ax
mov ds, ax
mov es, ax

; jump into long mode 
jmp gdt64.code:long_mode_start


section .text 
bits 64 
long_mode_start: 
	
	mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax

	hlt
