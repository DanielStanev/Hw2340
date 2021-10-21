#   Filename:       Hw2.asm
#   Author:         Daniel Stanev
#   Course:         CS 2340.005
#   Date:           20 Oct 2021
#   Assignment:     Pgm2
#   Language:       MIPS Assembly
#
#   Description: 

.data

    # program output
    prompt:     .asciiz     "Please Enter File Directory: "
    capitals:   .asciiz     "No. of Capitals:       "
    lowercase:  .asciiz     "No. of Lowercase:      "
    symbols:    .asciiz     "No. of Symbols:        "
    digits:     .asciiz     "No. of digits:         "
    signed:     .asciiz     "No. of signed numbers: "
    lines:      .asciiz     "No. of lines:          "
    newline:    .asciiz     "\n"

    # user input    
    filename:   .asciiz     "C:\\Files\\Projects\\MIPS\\Hw2340\\test.txt"
    content:    .space      4096

.text
main:
   
    #jal readInput  # reads in the file name from user input 
    jal readFile    # reads the entire file into a string
    jal initialize  # moves the string into a register and prepares saved registers for counting characters
    jal count       # counts the characters
    jal print       # prints the results

    # terminates program
    li $v0, 10
    syscall


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

initialize:
    la $s0, content # $s0 stores the contents of the file
    addi $s1, $0, 0 # $s1 stores the no. capitals
    addi $s2, $0, 0 # $s2 stores the no. lowercase
    addi $s3, $0, 0 # $s3 stores the no. symbols
    addi $s4, $0, 0 # $s4 stores the no. digits
    addi $s5, $0, 0 # $s5 stores the no. signed numbers
    addi $s6, $0, 1 # $s6 stores the no. lines (starts at 1 bc there is always 1 more line than newline chars)
    
    jr $ra          # returns to the call

count:
    move $s7, $ra       # stores the return address in $s7 since more calls are made
    addi $a0, $0, 0     # $a0 is the index of the string
    while:
        add $a1, $s0, $a0       # $a1 stores the address of the character at the current index
        lb $a2, ($a1)           # $a2 stores the actual character at the index
        beq $a2, $zero, exit    # exits loop if end of the string is reached

        jal checkCap    # Checks if current char is a capital
        jal checkLower  # Checks if current char is lowercase
        jal checkSymbol # Checks if current char is a symbol/ and part of a signed number (- and + are included in both counts)
        jal checkDigit  # Checks if current char is a digit
        jal checkLine   # Checks if current char is a newline

        addi $a0, $a0, 1 # increments the index of the string

        j while         # jumps to start of loop
    exit:
        jr $s7          # returns to the function call once the loop ends

checkCap:
    # exits the function if $a2 is out of the bounds
    blt $a2, 'A', exitCap 
    bgt $a2, 'Z', exitCap

    # adds 1 to the capital counter if in bound
    addi $s1, $s1, 1

    # returns to the procedure count:
    exitCap:
        jr $ra  

checkLower:
    # exits the function if $a2 is out of the bounds
    blt $a2, 'a', exitLow
    bgt $a2, 'z', exitLow

    # adds 1 to the lowercase counter if in bound
    addi $s2, $s2, 1  

    # returns to the procedure count:
    exitLow:
        jr $ra 

checkSymbol:
    jr $ra

checkDigit:
    # exits the function if $a2 is out of the bounds
    blt $a2, '0', exitDigit
    bgt $a2, '9', exitDigit

    # adds 1 to the digit counter if in bound
    addi $s4, $s4, 1  

    # returns to the procedure count:
    exitDigit:
        jr $ra

checkLine:
    # exits the function if $a2 is not '\n'
    bne $a2, '\n', exitLine

    # adds 1 to the line counter if in bound
    addi $s6, $s6, 1  

    # returns to the procedure count:
    exitLine:
        jr $ra

print:
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

insertNewline:
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra
