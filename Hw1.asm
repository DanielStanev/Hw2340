#   Filename:       Hw1.asm
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
    li $v0, 4       # Loads 4 into v0
    la $a0, promptA # Loads "A: " into a0
    syscall         # Print "A: " to console
    
    # Stores in the input into $t0
    li $v0, 5       # Loads 5 into v0
    syscall         # Stores user input into v0
    move $t0, $v0   # Moves the result from v0 into t1
    
    # Prompt the user for int B
    li $v0, 4       # Loads 4 into v0
    la $a0, promptB # Loads "B: " into a0
    syscall         # Print "B: " to console
    
    # Stores in the input into $t1
    li $v0, 5       # Loads 5 into v0
    syscall         # Stores user input into v0
    move $t1, $v0   # Moves the result from v0 into t1

    # outputs A + B
    li $v0, 4       # Loads 4 into v0
    la $a0, output1 # Loads "A + B = " into a0
    syscall         # Print "A + B = " to console

    # Prints the answer to A + B
    li $v0, 1           # Loads 1 into v0
    add $a0, $t0, $t1   # Stores t0 + t1 into a0
    syscall             # Prints the value of a0 to console

    jal insertNewline # Calls procedure to insert a newline character
    
    # outputs A - B
    li $v0, 4       # Loads 4 into v0
    la $a0, output2 # Loads "A - B = " into a0
    syscall         # Print "A - B = " to console

    # Prints answer to A - B
    li $v0, 1           # Loads 1 into v0
    sub $a0, $t0, $t1   # Stores t0 - t1 into a0
    syscall             # Prints the value of a0 to console

    jal insertNewline # Calls procedure to insert a newline character

    # outputs B - A
    li $v0, 4       # Loads 4 into v0
    la $a0, output3 # Loads "B - A = " into a0
    syscall         # Print "B - A = " to console

    # Prints answer to B - A
    li $v0, 1           # Loads 1 into v0
    sub $a0, $t1, $t0   # Stores t1 - t0 into a0
    syscall             # Prints the value of a0 to console

    jal insertNewline # Calls procedure to insert a newline character

    # outputs A * B
    li $v0, 4       # Loads 4 into v0
    la $a0, output4 # Loads "A * B = " into a0
    syscall         # Print "A * B = " to console

    # Prints answer to A * B
    li $v0, 1           # Loads 1 into v0
    mul $a0, $t0, $t1   # Stores t0 * t1 into a0
    syscall             # Prints the value of a0 to console

    jal insertNewline # Calls precedure to insert a newline character

    # Outputs A / B
    li $v0, 4       # Loads 4 into v0
    la $a0, output5 # Loads "A / B = " into a0
    syscall         # Print "A / B = " to console

    # Prints answer to A / B
    div $t0, $t1    # Stores t0 / t1 into lo register and t0 % t1 into hi register
    li $v0, 1       # Loads 1 into v0
    mflo $a0        # Stores the value of the lo register to a0
    syscall         # Prints the value of a0 to console

    # Prints " Remainder "
    li $v0, 4           # Loads 4 into v0
    la $a0, remainder   # Loads " Remainder " into a0
    syscall             # Print " Remainder " to console

    # Prints answer to A % B
    li $v0, 1   # Loads 1 into v0
    mfhi $a0    # Stores the value of the hi register into a0
    syscall     # Prints the value of a0 to console

    jal insertNewline # Calls procedure to insert a newline character

    # Outputs B / A
    li $v0, 4       # Loads 4 into v0
    la $a0, output6 # Loads "B / A = " into a0
    syscall         # Print "B / A = " to console

    # Prints out the answer to B / A
    div $t1, $t0    # Stores t1 / t0 into lo register and t1 % t0 into hi register
    li $v0, 1       # Loads 1 into v0
    mflo $a0        # Stores the value of the lo register into a0
    syscall         # Prints the value of a0 to console

    # Prints " Remainder "
    li $v0, 4           # Loads 4 into v0
    la $a0, remainder   # Loads " Remainder " into a0
    syscall             # Print " Remainder " to console

    # Prints out B % A
    li $v0, 1   # Loads 1 into v0
    mfhi $a0    # Stores the value of the hi register into a0
    syscall     # Prints the value of a0 to console

    # Terminates Program by issuing syscall code 10
    li $v0, 10  # Loads 10 into v0
    syscall     # Terminates Program 

# Procedure to print a newline character
insertNewline:
    li $v0, 11      # Loads 11 into v0 to signify printing a single character
    la $a0, '\n'    # Loads '\n' into a0
    syscall         # Prints '\n'
    jr $ra          # Returns back to where it was called from
