
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