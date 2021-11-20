#   Filename:       Hw3.asm
#   Author:         Daniel Stanev
#   Course:         CS 2340.005
#   Date:           20 Nov 2021
#   Assignment:     Pgm3
#   Language:       MIPS Assembly
#
#   Description: Takes in 
#   user input for a file name and
#   reads in strings representing binary, decimal,
#   hexadecimal numbers and converts them to one of
#   the three types
#
#   Procedures:
#   main:           calls proceducers to read/write
#   openFile:       prompts user for input and opens file
#   readInputSize:  extracts value from binary string in file
#   initialize:     Sets all the registers for counting to 0
#   readBinary:     extracts value from binary string in file
#   readDecimal:    extracts value from decimal string in file
#   readHex:        extracts value from hexadecimal string in file
#   printDecimal:   prints value in base 10
#   getPower:       collects base^exponent

.data

	prompt:		.asciiz	"Please enter full path of file: "
    
    binInput:   .asciiz "b: "
    decInput:   .asciiz "d: "
    hexInput:   .asciiz "h: "


    binOutput:  .asciiz "; B: "
    decOutput:  .asciiz "; D: "
    hexOutput:  .asciiz "; H: "

    filename:   .space  256
    buffer:     .space  1
    bufferLen:  .word   1

.text

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      main
#   Purpose:        Calls other procedures to read file input and out to console
main:

    jal openFile                        # prompts the user for a filename and opens it

    while:
        jal readByte

        # checks the input type
        beq $a3, 'b', readBinary        # extracts the value from a binary string
        beq $a3, 'd', readDecimal       # extracts the value from a decimal string
        beq $a3, 'h', readHex           # extracts the value from a hexadecimal string

        j while                         # eeturns to the top of the loop if the character read was neither

        output:

        mult $s3, $s5                   # handles numbers explicitly signed
        mflo $s5                        # $s5 stores the value

        # checks the output type
        #beq $s2, 'B', printBinary      # handles binary output (INCOMPLETE)
        beq $s2, 'D', printDecimal      # handles decimal output
        #beq $a3, 'H', hexOutput        # handles hexadecimal output (INCOMPLETE)

        j while                         # returns to top of loop
    exit:

    li $v0, 16                          # closes the file
    syscall

    li $v0, 10                          # terminates the program
    syscall

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      openFile
#   Purpose:        Prompts user for input and opens file
#   Arguements:     $s0, returns file descriptor
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
    addi $t0, $0, 0                     # $t0 is the index of the string
    findNewline:
        add $t1, $a0, $t0               # $t1 stores the address of the character at the current index
        lb $t2, ($t1)                   # $t2 stores the actual character at the index
        beq $t2, '\n', open

        addi $t0, $t0, 1                # increments the index of the string
        j findNewline

    # Opens the file
    open:
    sb $0, ($t1)                        # since the newline character is the last, the string is ended one char earlier
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $s0, $v0                       # stores the file descriptor in $s0
    
    jr $ra                              # returns main

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      readByte
#   Purpose:        Prompts user for input and opens file
#   Arguements:     $s0, returns updated file descriptor
#                   $a3, character read
readByte:

    # reads in 1 character from the file
    li  $v0, 14
    add $a0, $s0, $zero                 # moves file descriptor to $a0 for reading
    la  $a1, buffer
    li  $a2, 1
    syscall

    beq $v0, 0, exit                    # proceeds to exit if the EOF is reached

    add $s0, $a0, $zero                 # updates the file descriptor in $s0
    lb  $a3, ($a1)                      # stores the character is $a3

    jr $ra 

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      readInputSize
#   Purpose:        reads the size of the input
#   Arguements:     $a3, character read
#                   $s1, returns number of characters in input
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

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      readBinary
#   Purpose:        extracts value from binary string in file
#   Arguements:     $s5, value of the number 
#                   $s3, explicit sign of number
#                   $s2, output type
readBinary:
    jal readInputSize                   # reads the input size

    blt $s1, 10, binaryProcess          # if the input size is less than 10, then the output type was already read
    jal readByte                        # reads an additional byte

    binaryProcess:
    move $s2, $a3                       # $s2 stores the output type

    # skims over the ':' and ' ' chars in the input file
    jal readByte                        # reads in next char from the file
    jal readByte                        # reads in nect char from the file          

    li $s3, 1                           # $s3 stores the sign of the number (positive by default)
    li $s5, 0                           # $s5 stores decimal representation of the number

    # starts the output with a "b: "
    li $v0, 4
    la $a0, binInput
    syscall

    binaryLoop:

    jal readByte                        # reads in next char from the file

    # prints the input to the screen byte by byte
    li  $v0, 11
    add $a0, $a3, $zero                 # copies the byte from $a3 to $a0
    syscall                         

    beq $a3, ' ', binaryLoop            # ignores spaces for digit grouping in calculations

    # s1 is used to represent the power of the current digit
    addi $s1, $s1, -1                   # decrements the exponent
    bltz $s1, output                    # when $s1 dips below zero there are no more digits to convert

    # adjusts the sign of the number if needed
    bne $a3, '-', getBinaryDigit        # detects explicit sign convertion
    li $s3, -1                          # changes to a negative sign

    getBinaryDigit:
    bne $a3, '1', binaryLoop            # if its not a 1, it doesn't contribute to the value of a binary number

    # calculates the exponent of the base in the current digit
    addi $s4, $zero, 2                  # $s4 holds that base
    jal getPower                        # $s4 now holds that base raised to the correct power

    add $s5, $s5, $s4                   # for binary, adds the base^exponent to the total value if digit is 1

    j binaryLoop                        # returns to the top of the loop

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      readDecimal
#   Purpose:        extracts value from decimal string in file
#   Arguements:     $s5, value of the number 
#                   $s3, explicit sign of number
#                   $s2, output type
readDecimal:
    jal readInputSize
    blt $s0, 10, decimalProcess         # if the input size is less than 10, then the output type was already read
    jal readByte                        # reads an additional byte

    decimalProcess:
    move $s2, $a3                       # $s2 stores the output type

    # skims over the ':' and ' ' chars in the input file
    jal readByte                        # reads in next char from the file
    jal readByte                        # reads in nect char from the file          

    li $s3, 1                           # $s3 stores the sign of the number (positive by default)
    li $s5, 0                           # $s5 stores decimal representation of the number

    # starts the output with a "d: "
    li $v0, 4
    la $a0, decInput
    syscall

    decimalLoop:

    jal readByte                        # reads in next char from the file

    # prints the input to the screen byte by byte
    li  $v0, 11
    add $a0, $a3, $zero                 # copies the byte from $a3 to $a0
    syscall                         

    beq $a3, ' ', decimalLoop           # ignores spaces for digit grouping, in calculations
    beq $a3, ',', decimalLoop           # ignores commas for digit grouping, in calculations

    # s1 is used to represent the power of the current digit
    addi $s1, $s1, -1                   # decrements the exponent
    bltz $s1, output                    # when $s1 dips below zero there are no more digits to convert

    # adjusts the sign of the number if needed
    bne $a3, '-', getDecimalDigit       # detects explicit sign convertion
    li $s3, -1                          # changes to a negative sign

    getDecimalDigit:
    addi $a3, $a3, -48
    bgt $a3, 9, decimalLoop             # if its not a 1-9 it doesn't contribute the value of a decimal number
    blt $a3, 1, decimalLoop

    # calculates the exponent of the base in the current digit
    addi $s4, $zero, 10                 # $s4 holds that base
    jal getPower                        # $s4 now holds that base raised to the correct power

    mult $s4, $a3                       # multiplies $s4 by the value at that digit
    mflo $s4                            # $s4 holds base^exponent * digit

    add $s5, $s5, $s4                   # adds the base^exponent * digit to the total value

    j decimalLoop                       # returns to the top of the loop

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      readHex
#   Purpose:        extracts value from hexadecimal string in file
#   Arguements:     $s5, value of the number 
#                   $s3, explicit sign of number
#                   $s2, output type
readHex:
    jal readInputSize
    blt $s0, 10, hexProcess             # if the input size is less than 10, then the output type was already read
    jal readByte                        # reads an additional byte

    hexProcess:
    move $s2, $a3                       # $s2 stores the output type

    # skims over the ':' and ' ' chars in the input file
    jal readByte                        # reads in next char from the file
    jal readByte                        # reads in nect char from the file          

    li $s3, 1                           # $s3 stores the sign of the number (positive by default)
    li $s5, 0                           # $s5 stores decimal representation of the number

    # starts the output with a "H: "
    li $v0, 4
    la $a0, hexInput
    syscall

    hexLoop:

    jal readByte                        # reads in next char from the file

    # prints the input to the screen byte by byte
    li  $v0, 11
    add $a0, $a3, $zero                 # copies the byte from $a3 to $a0
    syscall                         

    beq $a3, ' ', hexLoop               # ignores spaces for digit grouping, in calculations
    beq $a3, ',', hexLoop               # ignores commas for digit grouping, in calculations

    # s1 is used to represent the power of the current digit
    addi $s1, $s1, -1                   # decrements the exponent
    bltz $s1, output                    # when $s1 dips below zero there are no more digits to convert

    # adjusts the sign of the number if needed
    bne $a3, '-', getHexDigit           # detects explicit sign convertion
    li $s3, -1                          # changes to a negative sign

    getHexDigit:
    addi $a3, $a3, -48                  # adjusts values 1-9    

    # Checks if the byte is a hex digit         
    blt $a3, 1, hexLoop
    ble $a3, 9, hexCalc
    blt $a3, 17, hexLoop                # 17 corresponds to A before the second adjustment
    bgt $a3, 22, hexLoop                # 22 corresponds to F before the second adjustment

    addi $a3, $a3, -7                   # second adjustment for A-F

    hexCalc:
    # calculates the exponent of the base in the current digit
    addi $s4, $zero, 16                 # $s4 holds that base
    jal getPower                        # $s4 now holds that base raised to the correct power

    mult $s4, $a3                       # multiplies $s4 by the value at that digit
    mflo $s4                            # $s4 holds base^exponent * digit

    add $s5, $s5, $s4                   # adds the base^exponent * digit to the total value

    j hexLoop                           # returns to the top of the loop

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      printDecimal
#   Purpose:        prints the value in base 10
#   Arguements:     $s5, value of the number
#                   $s2, output type
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

    li $s2, 0                           # sets $s2 to 0 so that printDecimal will not execute until next value of $s2

    j while                             # returns to while loop in main

#   Author:         Daniel Stanev
#   Date Created:   20 Nov 2021
#   Procedure:      getPower
#   Purpose:        collects base^exponent 
#   Arguements:     $s4, base^exponent
#                   $s1, exponent
getPower:
    add $t1, $zero, $s4                 # stores the base in $t1
    li  $t0, 0                          # initializes $t0 to 0

    bne $s1, $zero, powerLoop           # enters loop if exponent is not 0
    li  $s4, 1
    jr $ra                              # returns to call 

    powerLoop:

    addi $t0, $t0, 1                    # updated exponent check
    beq  $t0, $s1, exitPowerLoop        # exits when exponent has been reached

    mult $s4, $t1                       # multiplies $s4 by base until s4 = base^exponent
    mflo  $s4

    j powerLoop                         # returns to top of the loop

    exitPowerLoop:                      # loop exit
    jr $ra



#   TODO: fix the printBinary procedure
#   TODO: implement the printHex procedure
# 
# printBinary:
#     # prints out "B: " in preparation for binary out
#     li $v0, 4
#     la $a0, binOutput
#     syscall

#     li $t0, 1
#     li $t1, 32 
#     li $t2, -2147483648

#     binPrint:
#     bgt $t0, $t1, exitBin

#     divu $s5, $t2
#     mflo $a0
#     mfhi $s5

#     li $v0, 11
#     addi $a0, $a0, 48
#     syscall

#     addi $t0, $t0, 1
#     j binPrint

#     exitBin:
#     jr $ra

# printHex: