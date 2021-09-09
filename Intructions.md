Creating variables
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
                    li      $v0,    4
                    la      $a0,    chr
                    syscall
    String:
                    li      $v0,    4
                    la      $a0,    str
                    syscall