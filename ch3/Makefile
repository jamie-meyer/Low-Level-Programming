
run:
	nasm lib.asm -felf64 -o lib.o
	nasm dict.asm -felf64 -o dict.o
	nasm main.asm -felf64 -o main.o
	ld main.o lib.o dict.o -o main
debug:
	nasm -E lib.asm
