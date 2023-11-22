
https://www.cs.utexas.edu/~dahlin/Classes/UGOS/reading/gdb-ref.pdf



gcc -g
set disassembly-flavor intel

starti : breakpoint start of the programme

si : go into
ni : next instruction (not go into)

display/15i $rip : print each time we stop
x/20x addr
p/x addr

info proc map

catch syscall write

i r rip


set follow-fork-mode child


![[Pasted image 20231115221321.png]]

![[Pasted image 20231115221334.png]]

