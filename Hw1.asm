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
    promptA:	.asciiz		"A: "
    promptB:	.asciiz		"B: "
    newline:    .byte       '\n'
    output1:    .asciiz     "A + B = "
    output2:    .asciiz     "A - B = "
    output3:    .asciiz     "B - A = "
    output4:    .asciiz     "A * B = "
    output5:    .asciiz     "A / B = "
    output6:    .asciiz     "B / A = "
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

    #outputs A + B
    li $v0, 4
    la $a0, output1
    syscall
    li $v0, 1
    add $a0, $t0, $t1
    syscall
    
    #terminates program
    li $v0, 10
    syscall
