Vocab:
    bit:        binary digit; a 0 or 1
    byte:       8 bits
    word:       4 bytes or 32 bits
    RAM:        Random Access Memory, where variables are stored
    Register:   Memory on the CPU, used to perform operations, MIPS processors have 32 registers

Registers:
    In order to perform operations, the values must be loaded in 
    the CPU Registers and NOT just in Random Access Memory.

Creating variables (loads into RAM):

    Integer:        myInt:      .word       12
    Float:          myFlt:      .float      3.14
    Double:         myDub:      .double     6.28
    Character:      myChr:      .byte       'a'
    String:         myStr:      .asciiz     "Hello Guys\n"

Printing a variable:
    Integer:
                    li      $v0,    1
                    lw      $a0,    num
                    syscall
    Float:
                    li      $v0,    2
                    lwcl    $f12,   num
                    syscall
    Double:
                    li      $v0,    3
                    ldc1    $f12,   num
                    syscall   
    Character:
                    li      $v0,    11
                    la      $a0,    chr
                    syscall
    String:
                    li      $v0,    4
                    la      $a0,    str
                    syscall

Mathematical Operations:
    
    add $a0, $t0, $t1 == a0 = t0 + t1
    sub $a0, $t0, $t1 == a0 = t0 - t1
    mul $a0, $t0, $t1 == a0 = t0 * t1
