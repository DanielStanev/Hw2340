#   Filename:       Hw2.asm
#   Author:         Daniel Stanev
#   Course:         CS 2340.005
#   Date:           21 Oct 2021
#   Assignment:     Pgm2
#   Language:       MIPS Assembly
#
#   Description: Takes in 
#   user input for a file name and
#   prints out the total number of
#   captials, lowercase letters, digits
#   symbols, signed numbers and lines.
#
#   Procedures:
#   main:           Executes five main procedures in order
#   readInput:      Takes in user input for file location
#   readFile:       Stores the contents of file into a string
#   initialize:     Sets all the registers for counting to 0
#   count:          Counts each character using sub-procedures
#   print:          Prints the results
#   checkCap:       Checks for capital letters
#   checkLower:     Checks for lowercase lettres
#   checkSymbol:    Checks for symbols
#   checkDigit:     Checks for digits
#   checkSigned:    Checks for signed numbers
#   checkLine:      Checks for newline characters
#   insertNewline:  Prints a newline char to the console

.data

    # program output
    prompt:     .asciiz     "Please Enter Full Path Of A File: "
    capitals:   .asciiz     "No. of Capitals:       "
    lowercase:  .asciiz     "No. of Lowercase:      "
    symbols:    .asciiz     "No. of Symbols:        "
    digits:     .asciiz     "No. of digits:         "
    signed:     .asciiz     "No. of signed numbers: "
    lines:      .asciiz     "No. of lines:          "
    newline:    .asciiz     "\n"

    # user input    
    filename:   .space      256
    content:    .space      4096

.text

#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Purpose:        Executes the five main procedures required to gather the data from a file
main:
   
    jal readInput   # reads in the file name from user input 
    jal readFile    # reads the entire file into a string
    jal initialize  # moves the string into a register and prepares saved registers for counting characters
    jal count       # counts the characters
    jal print       # prints the results

    # terminates program
    li $v0, 10
    syscall


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Purpose:        Prompts and stores user input for location of a file
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
        beq $t2, '\n', removeNewline

        addi $t0, $t0, 1    # increments the index of the string
        j findNewline
    removeNewline:
    sb $0, ($t1)    # since the newline character is the last, the string is ended one char earlier
    jr $ra


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Purpose:        Stores contents of a file into a string
readFile:

    # opens the file
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall

    # reads the file
    move $a0, $v0
    li $v0, 14
    la $a1, content
    li $a2, 4096
    syscall

    # closes the file
    li $v0, 16
    syscall

    # returns to the function call in main
    jr $ra


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Purpose:        Initialize registers to make counting easier
initialize:
    la $s0, content # $s0 stores the contents of the file
    addi $s1, $0, 0 # $s1 stores the no. capitals
    addi $s2, $0, 0 # $s2 stores the no. lowercase
    addi $s3, $0, 0 # $s3 stores the no. symbols
    addi $s4, $0, 0 # $s4 stores the no. digits
    addi $s5, $0, 0 # $s5 stores the no. signed numbers
    addi $s6, $0, 1 # $s6 stores the no. lines (starts at 1 bc there is always 1 more line than newline chars)
    
    jr $ra          # returns to the call


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a0
#   Purpose:        Counts the stats of the contents of the file read
count:
    move $s7, $ra       # stores the return address in $s7 since more calls are made
    addi $a0, $0, 0     # $a0 is the index of the string
    while:
        add $a1, $s0, $a0       # $a1 stores the address of the character at the current index
        lb $a2, ($a1)           # $a2 stores the actual character at the index
        beq $a2, $zero, exit    # exits loop if end of the string is reached

        jal checkCap    # Checks if current char is a capital
        jal checkLower  # Checks if current char is lowercase
        jal checkSymbol # Checks if current char is a symbol
        jal checkDigit  # Checks if current char is a digit
        jal checkSigned # Checks if current char is a sign
        jal checkLine   # Checks if current char is a newline

        addi $a0, $a0, 1 # increments the index of the string

        j while         # jumps to start of loop
    exit:
        jr $s7          # returns to the function call once the loop ends


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if a char is a capital letter
checkCap:
    # exits the function if $a2 is out of the bounds
    blt $a2, 'A', exitCap 
    bgt $a2, 'Z', exitCap

    # adds 1 to the capital counter if in bound
    addi $s1, $s1, 1

    # returns to the procedure count:
    exitCap:
        jr $ra  


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if a char is a lowercase letter
checkLower:
    # exits the function if $a2 is out of the bounds
    blt $a2, 'a', exitLow
    bgt $a2, 'z', exitLow

    # adds 1 to the lowercase counter if in bound
    addi $s2, $s2, 1  

    # returns to the procedure count:
    exitLow:
        jr $ra 


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if a char is a symbol
checkSymbol:
    # exits if $a2 is a digit
    blt $a2, '0', caps 
    bgt $a2, '9', caps
    jr $ra

    # exits if $a2 is a capital
    caps:
        blt $a2, 'A', lows 
        bgt $a2, 'Z', lows
        jr $ra

    # exits if $a2 is a lowercase
    lows:
        blt $a2, 'a', line 
        bgt $a2, 'z', line
        jr $ra

    # exits if $a2 is a newline char
    line: 
        bne $a2, '\n', symbol
        jr $ra

    # increments the symbol counter
    symbol:
        addi $s3, $s3, 1
        jr $ra

#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if a char is a digit
checkDigit:
    # exits the function if $a2 is out of the bounds
    blt $a2, '0', exitDigit
    bgt $a2, '9', exitDigit

    # adds 1 to the digit counter if in bound
    addi $s4, $s4, 1  

    # returns to the procedure count:
    exitDigit:
        jr $ra

#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if a symbol is part of a signed number
checkSigned:
    # checks if the char is a '+' or a '-'
    beq $a2, '+', checkNext
    beq $a2, '-', checkNext

    # returns to the procedure count:
    exitSigned:
        jr $ra

    # if the next char is a digit then the sign is part of a signed number
    checkNext:
        # Stores the next char in $t1
        add $t0, $s0, $a0
        addi $t0, $t0, 1
        lb $t1, ($t0)

        # exits the function if $t1 is not a digit
        blt $t1, '0', exitSigned
        bgt $t1, '9', exitSigned

        # increments the signed counter by 1 and exits procedure
        addi $s5, $s5, 1
        j exitSigned

#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguement:      $a2
#   Purpose:        Checks if the current index is a '\n' char
checkLine:
    # exits the function if $a2 is not '\n'
    bne $a2, '\n', exitLine

    # adds 1 to the line counter if in bound
    addi $s6, $s6, 1  

    # returns to the procedure count:
    exitLine:
        jr $ra

#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Arguements:     $s1-$s6
#   Purpose:        Print out the stats of the file
print:

    # since other procedure calls are made the return address is stored in a saved register
    move $s7, $ra

    # prints the number of capitals
    jal insertNewline
    la $a0, capitals    
    syscall
    li $v0, 1
    addi $a0, $s1, 0
    syscall           

    # prints the number of lowercase
    jal insertNewline
    la $a0, lowercase
    syscall
    li $v0, 1
    addi $a0, $s2, 0
    syscall

    # prints the number of symbols (- and + count towards signed numbers and symbols)
    jal insertNewline
    la $a0, symbols
    syscall
    li $v0, 1
    addi $a0, $s3, 0
    syscall

    # prints the number of digits
    jal insertNewline
    la $a0, digits
    syscall
    li $v0, 1
    addi $a0, $s4, 0
    syscall

    # prints the number of signed numbers (- and + count towards signed numbers and symbols)
    jal insertNewline
    la $a0, signed
    syscall
    li $v0, 1
    addi $a0, $s5, 0
    syscall

    # prints the number of lines in the file
    jal insertNewline
    la $a0, lines
    syscall
    li $v0, 1
    addi $a0, $s6, 0
    syscall

    # jumps back to where count was called in main
    jr $s7


#   Author:         Daniel Stanev
#   Date Created:   21 Oct 2021
#   Purpose:        Print a '\n' to the console
insertNewline:
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra