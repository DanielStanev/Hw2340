
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

        beq $a3, 'b', readBinary
        beq $a3, 'd', readDecimal
        beq $a3, 'h', readHex

        output:

        # checks the output type
        #beq $a3, 'B', binaryOutput
        #beq $a3, 'D', decimalOutput
        #beq $a3, 'H', hexOutput

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

readInputSize: 
    jal readByte
    addi $t0, $a3, -48
    jal readByte
    bgt $a3, '9', singleDigit

    # processes a 2 digit input length
    addi $t1, $zero, 10
    mult $t0, $t1
    mflo $t0
    add $s1, $t0, $a3
    addi $s1, $s1, -48

    jr $ra 

    singleDigit:
    addi $s1, $t0, 0        # s1 stores the number of digits

    jr $ra

readBinary:
    jal readInputSize
    blt $s0, 10, binaryProcess
    jal readByte

    binaryProcess:
    move $s2, $a3           # $s2 stores the output type

    # discards the ':' abd ' ' chars in the input file
    jal readByte            # reads in next char from the file
    jal readByte            # reads in nect char from the file          


    li $s3, 1               # $s3 stores the sign of the number (positive by default)

    binaryLoop:

    # s1 is used to represent the power of the current digit
    addi $s1, -1
    bltz $s1, output        # when $s1 dips below zero there are no more digits to convert

    jal readByte            # reads in next char from the file

    # adjusts the sign of the number if needed
    bne $a3, '-', getBinaryDigit
    li $s3, -1

    getBinaryDigit:
    bgt 


    j binaryLoop

readDecimal:
readHex:
printDecimal:
printBinary:
printHex:
