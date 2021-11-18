
.data

	prompt:		.asciiz	"Please enter full path of file: "

    filename:   .space  256
    buffer:     .space  1
    bufferLen:  .word   1

.text
main:

    jal readInput
    jal readByte


    li $v0, 10
    syscall

readInput:
    
    # prompts the user for input
    li $v0, 4
    la $a0, prompt
    syscall

    # stores user input
    li $v0, 8
    la $a0, filename
    li $a1, 256
    syscall

    # finds where the newline character is in a string
    addi $t0, $0, 0     # $t0 is the index of the string
    findNewline:
        add $t1, $a0, $t0       # $t1 stores the address of the character at the current index
        lb $t2, ($t1)           # $t2 stores the actual character at the index
        beq $t2, '\n', openFile

        addi $t0, $t0, 1    # increments the index of the string
        j findNewline
    openFile:
    sb $0, ($t1)    # since the newline character is the last, the string is ended one char earlier
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $s0, $v0
    jr $ra


readByte:

    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $a0, $v0

    li $v0, 14
    la $a1, buffer
    lb $a2, bufferLen
    syscall

    li $v0, 4
    la $a0, buffer
    syscall

    jr $ra 


readFile:
readBinary:
readDecimal:
readHex:
printDecimal:
printBinary:
printHex:
