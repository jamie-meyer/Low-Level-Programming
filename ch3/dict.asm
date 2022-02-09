

section .text

extern string_equals
extern string_length
extern print_string
extern exit

global find_word

find_word:
	mov r9, rdi
	push rdi
.loop:
	mov rdi, rsi
	push rsi
	mov rsi, r9
	call string_equals
	pop rsi
	cmp rax, 1
 	je .done
	cmp dword [rsi-8], 0
        je .not_found
	mov rsi, [rsi-8]
	jmp .loop
.not_found:
	mov rsi, 0
.done:
	pop rdi
	mov rax, rsi
	ret
