
.data

	prompt:		.asciiz	"Please enter full path of file: "

    filename:   .space  256
    buffer:     .space  1
    bufferLen:  .word   1

.text
main:

    jal openFile
    while:
        jal readByte

        # checks the input type
        beq $a3, 'b', binaryInput
        beq $a3, 'd', decimalInput
        beq $a3, 'h', hexInput

        # calls procedure to read given input type
        binaryInput:
            jal readBinary
            j output
        decimalInput:
            jal readDecimal
            j output
        hexInput:
            jal readHex
            j output

        output:
        # checks the output type
        beq $a3, 'B', binaryOutput
        beq $a3, 'D', decimalOutput
        beq $a3, 'H', hexOutput

        binaryOutput:
            jal printBinary
        decimalInput:
        hexInput:


        


        j while
    exit:

    li $v0, 10
    syscall

openFile:
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
    addi $t0, $0, 0             # $t0 is the index of the string
    findNewline:
        add $t1, $a0, $t0       # $t1 stores the address of the character at the current index
        lb $t2, ($t1)           # $t2 stores the actual character at the index
        beq $t2, '\n', open

        addi $t0, $t0, 1        # increments the index of the string
        j findNewline

    # Opens the file
    open:
    sb $0, ($t1)                # since the newline character is the last, the string is ended one char earlier
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $s0, $v0               # stores the file descriptor in $s0
    
    jr $ra                      # returns main


readByte:

    # reads in 1 character from the file
    li  $v0, 14
    add $a0, $s0, $zero
    la  $a1, buffer
    li  $a2, 1
    syscall

    add $s0, $a0, $zero         # updates the file descriptor in $s0
    lb  $a3, ($a1)              # stores the character is $a3

    jr $ra 


readFile:
readBinary:
readDecimal:
readHex:
printDecimal:
printBinary:
printHex:
