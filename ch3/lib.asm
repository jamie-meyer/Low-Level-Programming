global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global print_char
global print_word
global read_char
global read_word
global read_string
global parse_uint
global parse_int
global string_equals
global string_copy

section .text

;; Accepts an exit code and terminates current process.
exit:
	mov rax, 60
	syscall

;; Accepts a pointer to a string and returns its length
string_length:
	xor rax, rax
.loop:
	cmp byte [rdi+rax], 0
	je .end
	inc rax
	jmp .loop
.end:
	ret

;; Accepts a pointer to a null-terminated string and prints it to stdout
print_string:
	call string_length ;; rax now has length of string
	mov rdx, rax
	mov rax, 1
	mov rsi, rdi
	mov rdi, 1
	syscall
	ret

;; Accepts a character code directly as its first argument and prints it to stdout.
print_char:
	push rdi
	mov rax, 1
	mov rsi, rsp
	mov rdi, 1
	mov rdx, 1
	syscall
	pop rdi
	ret

;; Prints a character with code 0xA.
print_newline:
	mov rdi, 10
	call print_char
	ret

;; Outputs an unsigned 8-byte integer in decimal format.
print_uint:
	xor rax, rax
	push rax
	mov rax, rdi
	mov rcx, 10
	xor r8, r8
.loop:
	;mov rcx, 10
	mov rdx, 0
	div rcx
	add rdx, 48
	inc r8
	;mov rdi, rdx
	;call print_char
	push rdx
	cmp dword rax, 0
	je .pop_loop
	jmp .loop
.pop_loop:
	pop rdi
	call print_char
	dec r8
	cmp dword r8, 0
	jge .pop_loop
	call print_newline
	ret

;; Output a signed 8-byte integer in decimal format.
print_int:
	mov r8, 0x8000000000000000
	and r8, rdi
	cmp r8, 0
	je .uint
.sint:
	push rdi
	mov rdi, 45
	call print_char
	pop rdi
	xor rdi, -1
	add rdi, 1
.uint:
	call print_uint
	ret

;; Read one character from stdin and return it. If the end of input stream occurs, return 0.
read_char:
	xor rax, rax
	push rax
	mov rdx, 1
	mov rsi, rsp
        mov rdi, 0
        syscall
	pop rax
        ret

;; Accepts a buffer address and size as arguments. Reads next word from stdin (skipping whitespaces into buffer). Stops and returns 0 if word is too big for the buffer specified; otherwise returns a buffer address.
read_word:
	xor rbx, rbx
.loop:
	cmp rbx, rsi
	jg .fail
	push rdi
	push rbx
	push rsi
	call read_char
	pop rsi
	pop rbx
	pop rdi
	mov byte [rdi+rbx], al
	lea r8, [rdi+rbx]
	cmp byte [r8], 32
	jle .end
	cmp byte [r8], 127
	jge .end
	inc rbx
	jmp .loop
.fail:
	xor rax, rax
	ret
.end:
	mov byte [rdi+rbx], 0
	mov rax, rdi
	ret

;; Accepts a buffer address and size as arguments. Reads string from stdin into buffer.
read_string:
        xor rbx, rbx
.loop:
        cmp rbx, rsi
        jg .fail
        push rdi
        push rbx
        push rsi
        call read_char
        pop rsi
        pop rbx
        pop rdi
        mov byte [rdi+rbx], al
        lea r8, [rdi+rbx]
        cmp byte [r8], 10
        je .end
        inc rbx
        jmp .loop
.fail:
        xor rax, rax
        ret
.end:
        mov byte [rdi+rbx], 0
        mov rax, rdi
        ret

;; Accepts a pointer to a null-terminated string and tries to parse an unsigned number from its start. Returns the number parsed in rax, its character count in rdx.
parse_uint:
	call string_length
	mov rdx, rax
	xor rax, rax
	mov rbx, rdx
	mov r9, 10
	mov r10, 1
	cmp rbx, 0
	je .fail
.ten_loop:
	push rax
	mov rax, r10
	mul r9
	mov r10, rax
	pop rax
	sub rbx, 1
	cmp rbx, 1
	jg .ten_loop
	xor rbx, rbx
.loop:
	cmp byte [rdi+rbx], 0
	je .end
	xor r8, r8
	mov r8b, byte [rdi+rbx]
	sub r8, 48
	cmp r8b, 10
	jge .fail
	push rax
	xor rax, rax
	mov al, r8b
	mul r10
	mov r8, rax
	mov rax, r10
	push rdx
	xor rdx, rdx
	div r9
	pop rdx
	mov r10, rax
	pop rax
	add rax, r8
	inc rbx
	jmp .loop
.fail:
	xor rax, rax
	xor rdx, rdx
	ret
.end:
	ret


;; Accepts a null-terminated string and tries to parse a signed number from its start. Returns the number parsed in rax; its characters count in rdx (including sign if any). No spaces between sign and digits are allowed.
parse_int:
	cmp byte [rdi], 45
	jne .positive
	inc rdi
	call parse_uint
	xor rax, 0xFFFFFFFFFFFFFFFF
	inc rax
	inc rdx
	ret
.positive:
	call parse_uint
	ret

;; Accepts two pointers to null-terminated strings and compares them. Returns 1 if they are equal, otherwise 0.
string_equals:
	xor rdx, rdx
.loop:
	mov r8b, byte [rsi+rdx]
	cmp byte [rdi+rdx], r8b
	jne .fail
	cmp byte [rdi+rdx], 0
	je .equal
	inc rdx
	jmp .loop
.fail:
	xor rax, rax
	ret
.equal:
	mov rax, 1
	ret

;; Accepts a pointer to a string, a pointer to a buffer, and buffer's length. Copies string to the destination. The destination address is returned if the string fits the buffer; otherwise zero is returned.
string_copy:
	xor r8, r8
.loop:
	cmp r8, rdx
	je .end
	cmp byte [rdi+r8], 0
	je .end
	mov r9b, byte [rdi+r8]
	mov byte [rsi+r8], r9b
	inc r8
	jmp .loop
.fail:
	xor rax, rax
	ret
.end:
	mov byte [rsi+rdx], 0
	mov rax, rsi
	ret
