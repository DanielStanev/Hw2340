#   Author:         Daniel Stanev
#   Course:         CS 2340.005
#   Date:           08 Sep 2021
#   Assignment:     Pgm1
#   Language:       MIPS Assembly
#
#   Description: Reads in 2 integer inputs from the
#   console and displays their, sum, differences, 
#   product, and quotients.

.data 
    promptA:	.asciiz     "A: "
    promptB:	.asciiz     "B: "
    output1:    .asciiz     "A + B = "
    output2:    .asciiz     "A - B = "
    output3:    .asciiz     "B - A = "
    output4:    .asciiz     "A * B = "
    output5:    .asciiz     "A / B = "
    output6:    .asciiz     "B / A = "
    remainder:  .asciiz     " Remainder "
    error1:     .asciiz     "Undefined; B = 0"
    error2:     .asciiz     "Undefined; A = 0"

.text
main:

    # Prompt the user for int A
    li $v0, 4
    la $a0, promptA
    syscall
    
    # Stores in the input into $t0
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Prompt the user for int B
    li $v0, 4
    la $a0, promptB
    syscall
    
    # Stores in the input into $t1
    li $v0, 5
    syscall
    move $t1, $v0

    # outputs A + B
    # Prints "A + B = "
    li $v0, 4
    la $a0, output1
    syscall

    # Prints the answer to A + B
    li $v0, 1
    add $a0, $t0, $t1
    syscall

    jal insertNewline # Calls procedure to insert a newline character
    
    # outputs A - B
    # Prints "A - B = "
    li $v0, 4
    la $a0, output2
    syscall

    # Prints answer to A - B
    li $v0, 1
    sub $a0, $t0, $t1
    syscall

    jal insertNewline # Calls procedure to insert a newline character

    # outputs B - A
    # Prints "B - A = "
    li $v0, 4
    la $a0, output3
    syscall

    # Prints answer to B - A
    li $v0, 1
    sub $a0, $t1, $t0
    syscall

    jal insertNewline # Calls procedure to insert a newline character

    # outputs A * B
    # Prints "A * B = "
    li $v0, 4
    la $a0, output4
    syscall

    # Prints answer to A * B
    li $v0, 1
    mul $a0, $t0, $t1
    syscall

    jal insertNewline # Calls precedure to insert a newline character

    # Outputs A / B
    # Prints "A / B = "
    li $v0, 4
    la $a0, output5
    syscall

    # Prints answer to A / B
    div $t0, $t1
    li $v0, 1
    mflo $a0
    syscall

    # Prints " Remainder "
    li $v0, 4
    la $a0, remainder
    syscall

    # Prints answer to A % B
    li $v0, 1
    mfhi $a0
    syscall

    jal insertNewline # Calls procedure to insert a newline character

    # Outputs B / A
    # Prints "B / A = "
    li $v0, 4
    la $a0, output6
    syscall

    # Prints out the answer to B / A
    div $t1, $t0
    li $v0, 1
    mflo $a0
    syscall

    # Prints " Remainder "
    li $v0, 4
    la $a0, remainder
    syscall

    # Prints out B % A
    li $v0, 1
    mfhi $a0
    syscall

    # Terminates Program by issuing syscall code 10
    li $v0, 10
    syscall

# Procedure to print a newline character
insertNewline:
    li $v0, 11   # Loads 11 into v0 to signify printing a single character
    la $a0, '\n' # Loads '\n' into a0
    syscall      # Prints '\n'
    jr $ra       # Returns back to where it was called from
