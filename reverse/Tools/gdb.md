
https://www.cs.utexas.edu/~dahlin/Classes/UGOS/reading/gdb-ref.pdf



gcc -g
set disassembly-flavor intel

starti : breakpoint start of the programme

si : go into
ni : next instruction (not go into)

display/5i $rip : print each time we stop
x/20x addr
p/x addr
x/5wx $esp
p/c \*$rsi@15 => $10 = {65 'A', 97 'a', 50 '2', 65 'A', 97 'a', 54 '6', 65 'A', 97 'a', 48 '0', 65 'A', 98 'b', 52 '4', 65 'A', 98 'b', 56 '8'}
x/s @ 

info proc map

catch syscall write

i r rip

info functions
![[Pasted image 20240206220204.png]]


set follow-fork-mode child


![[Pasted image 20231115221321.png]]

![[Pasted image 20231115221334.png]]

