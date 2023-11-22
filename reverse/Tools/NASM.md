
nasm -f elf64 myhello.S # produce myhello.o 
gcc -no-pie myhello.o -o myhello 

nasm -f bin -o shell shell.S # produce directly the binary