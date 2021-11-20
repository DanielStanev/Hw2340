
.data

	prompt:		.asciiz	"Please enter full path of file: "
    
    binInput:   .asciiz "b: "
    decInput:   .asciiz "d: "
    hexInput:   .asciiz "h: "

    prepOut:    .asciiz "; "

    binOutput:  .asciiz "B: "
    decOutput:  .asciiz "D: "
    hexOutput:  .asciiz "H: "

    filename:   .space  256
    buffer:     .space  1
    bufferLen:  .word   1

.text
main:

    jal openFile                # prompts the user for a filename and opens it

    while:
        jal readByte

        beq $a3, 'b', readBinary
        beq $a3, 'd', readDecimal
        beq $a3, 'h', readHex

        output:

        # prints out "; " to the console in preparation for the output
        li $v0, 4
        la $a0, prepOut
        syscall

        # checks the output type
        #beq $a3, 'B', binaryOutput
        beq $s2, 'D', printDecimal
        #beq $a3, 'H', hexOutput

        j while
    exit:

    li $v0, 16
    syscall

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
    addi $t0, $0, 0                 # $t0 is the index of the string
    findNewline:
        add $t1, $a0, $t0           # $t1 stores the address of the character at the current index
        lb $t2, ($t1)               # $t2 stores the actual character at the index
        beq $t2, '\n', open

        addi $t0, $t0, 1            # increments the index of the string
        j findNewline

    # Opens the file
    open:
    sb $0, ($t1)                    # since the newline character is the last, the string is ended one char earlier
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $s0, $v0                   # stores the file descriptor in $s0
    
    jr $ra                          # returns main


readByte:

    # reads in 1 character from the file
    li  $v0, 14
    add $a0, $s0, $zero
    la  $a1, buffer
    li  $a2, 1
    syscall

    beq $v0, 0, exit                # proceeds to exit if the EOF is reached

    add $s0, $a0, $zero             # updates the file descriptor in $s0
    lb  $a3, ($a1)                  # stores the character is $a3

    jr $ra 

readInputSize: 
    move $t4, $ra                   # since calling readByte alters the value of $ra the return address must be stored

    jal readByte
    addi $t0, $a3, -48              # fixes the offset caused by the ascii value
    jal readByte
    bgt $a3, '9', singleDigit       # if the second char is a letter and not a number the input size is single digit

    # processes a 2 digit input length
    addi $t1, $zero, 10             # in a two digit output the first digit represents the 10s place
    mult $t0, $t1                   # multiplies the first digit by 10
    mflo $t0                        # stores the result in $t0
    add $s1, $t0, $a3               # adds the values of the first digit and second digit
    addi $s1, $s1, -48              # adjusts for the second digits ascii offset

    jr $t4                          # returns to the procedure call

    # processes a 1 digit input length
    singleDigit:
    addi $s1, $t0, 0                # s1 stores the number of digits

    jr $t4                          # returns to the function call

readBinary:
    jal readInputSize

    blt $s1, 10, binaryProcess      # if the input size is less than 10, then the output type was already read
    jal readByte                    # reads an additional byte

    binaryProcess:
    move $s2, $a3                   # $s2 stores the output type

    # skims over the ':' and ' ' chars in the input file
    jal readByte                    # reads in next char from the file
    jal readByte                    # reads in nect char from the file          

    li $s3, 1                       # $s3 stores the sign of the number (positive by default)
    li $s5, 0                       # $s5 stores decimal representation of the number

    # starts the output with a "b: "
    li $v0, 4
    la $a0, binInput
    syscall

    binaryLoop:

    jal readByte                    # reads in next char from the file

    # prints the input to the screen byte by byte
    li  $v0, 11
    add $a0, $a3, $zero             # copies the byte from $a3 to $a0
    syscall                         

    beq $a3, ' ', binaryLoop        # ignores spaces for digit grouping in calculations

    # s1 is used to represent the power of the current digit
    addi $s1, $s1, -1               # decrements the exponent
    bltz $s1, output                # when $s1 dips below zero there are no more digits to convert

    # adjusts the sign of the number if needed
    bne $a3, '-', getBinaryDigit    # detects explicit sign convertion
    li $s3, -1                      # changes to a negative sign

    getBinaryDigit:
    bne $a3, '1', binaryLoop        # if its not a 1, it doesn't contribute to the value of a binary number

    # calculates the exponent of the base in the current digit
    addi $s4, $zero, 2              # $s4 holds that base
    jal getPower                    # $s4 now holds that base raised to the correct power

    add $s5, $s5, $s4               # for binary, adds the base^exponent to the total value if digit is 1

    j binaryLoop                    # returns to the top of the loop

readDecimal:
    jal readInputSize
    blt $s0, 10, decimalProcess     # if the input size is less than 10, then the output type was already read
    jal readByte                    # reads an additional byte

    decimalProcess:
    move $s2, $a3                   # $s2 stores the output type

    # skims over the ':' and ' ' chars in the input file
    jal readByte                    # reads in next char from the file
    jal readByte                    # reads in nect char from the file          

    li $s3, 1                       # $s3 stores the sign of the number (positive by default)
    li $s5, 0                       # $s5 stores decimal representation of the number

    # starts the output with a "d: "
    li $v0, 4
    la $a0, decInput
    syscall

    decimalLoop:

    jal readByte                    # reads in next char from the file

    # prints the input to the screen byte by byte
    li  $v0, 11
    add $a0, $a3, $zero             # copies the byte from $a3 to $a0
    syscall                         

    beq $a3, ' ', decimalLoop       # ignores spaces for digit grouping, in calculations
    beq $a3, ',', decimalLoop       # ignores commas for digit grouping, in calculations

    # s1 is used to represent the power of the current digit
    addi $s1, $s1, -1               # decrements the exponent
    bltz $s1, output                # when $s1 dips below zero there are no more digits to convert

    # adjusts the sign of the number if needed
    bne $a3, '-', getDecimalDigit   # detects explicit sign convertion
    li $s3, -1                      # changes to a negative sign

    getDecimalDigit:
    addi $a3, $a3, -48
    bgt $a3, 9, decimalLoop        # if its not a 1-9 it doesn't contribute the value of a decimal number
    blt $a3, 1, decimalLoop

    # calculates the exponent of the base in the current digit
    addi $s4, $zero, 10             # $s4 holds that base
    jal getPower                    # $s4 now holds that base raised to the correct power

    mult $s4, $a3                   # multiplies $s4 by the value at that digit
    mflo $s4                        # $s4 holds base^exponent * digit

    add $s5, $s5, $s4               # adds the base^exponent * digit to the total value

    j decimalLoop                   # returns to the top of the loop

readHex:
printDecimal:
    # prints out "D: " in preparation for decimal out 
    li $v0, 4
    la $a0, decOutput
    syscall

    # prints out the decimal output
    li $v0, 1
    move $a0, $s5
    syscall

    # prints out a newline after the output
    li $v0, 11
    li $a0, '\n'
    syscall

    j while

printBinary:
printHex:
getPower:
    add $t1, $zero, $s4
    li  $t0, 0

    bne $s1, $zero, powerLoop
    li  $s4, 1
    jr $ra

    powerLoop:

    # $
    addi $t0, $t0, 1
    beq  $t0, $s1, exitPowerLoop

    mult $s4, $t1
    mflo  $s4

    j powerLoop

    exitPowerLoop:
    jr $ra
