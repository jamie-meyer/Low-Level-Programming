
extern colon

section .data

global third_word

dq second_word
colon "word 3", third_word
db "Hello!!! this is cool!", 0

dq first_word
colon "word 2", second_word
db "this is the second word!@", 0

dq 0
colon "word 1", first_word
db "first word! whaaaaaa", 0
