global _start
extern read_string
extern print_string
extern exit
extern find_word


section .data
%macro colon 2
%2:
db %1, 0
%endmacro

dq second_word
colon "word3", third_word
db "Hello!!! this is cool!", 0

dq first_word
colon "word 2", second_word
db "this is the second word!@", 0

dq 0
colon "word 1", first_word
db "first word! whaaaaaa", 0

input_str: db "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", 0

section .text
_start:
	mov rdi, input_str
	mov rsi, 255
	call read_string
	mov rdi, input_str
	mov rsi, third_word
	call find_word
	cmp rax, 0
	je .leave
	mov rdx, 0
.loop:
	cmp byte [rax+rdx], 0
	je .printer
	inc rdx
	jmp .loop
.printer:
	add rax, rdx
	inc rax
	mov rdi, rax
	call print_string
.leave:
	mov rdi, 0
	call exit
