
**RSP** : Stack pointer => top of the stack
**RBP** : Frame pointer => beginning of the frame
**RIP** : Instruction pointer => Next instruction to execute

**Call** : call instruction
**Ret** : Return
**jmp** : jump
**j[xx]** : jump with condition

**rep** : repeat 

**cmp** : src1 - src2
**test** : src1 & src2


**Calling convention** :  https://en.wikipedia.org/wiki/X86_calling_conventions#List_of_x86_calling_conventions
linux 64bits : rdi, rsi, rdx, rcx, r8, r9, stack
linux 32bis : on the stack

**Return convention**
linux : **RAX** et/ou **RDX**
