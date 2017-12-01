


.data

newline:  .asciiz "\n"
promptUser: .asciiz "Input Move: "
youWon: .asciiz "YOU WON!"
youLost: .asciiz "You suck ass"



.text
.globl _start



####################################################################
# This is the "main" of your program; Everything starts here.
####################################################################

_start:


	
	
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	li $a3 0
	li $t0 0
	li $t1 0
	li $t2 1
	
	addi $sp $sp -12
	sw $t0 0($sp)
	sw $t1 4($sp)
	sw $t2 8($sp)
	
	jal start_game
	addi $sp $sp 12
 	
	
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	li $a3 0
	li $t0 1
	addi $sp $sp -4
	sw $t0 0($sp)
	#jal merge_row
	
	addi $sp $sp 4
	
	move $a0 $v0
	li $v0 1
	#syscall
	
	
			
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	li $a3 2
	li $t0 0
	addi $sp $sp -4
	sw $t0 0($sp)
	#jal merge_col
	
	addi $sp $sp 4
	
	move $a0 $v0
	li $v0 1
	#syscall
	
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	li $a3 0 
	li $t0 0
	addi $sp $sp -4
	sw $t0 0($sp)
	#jal shift_row
	addi $sp $sp 4
	
	move $a0 $v0
	li $v0 1
	#syscall
	
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	li $a3 0 
	li $t0 0 
	addi $sp $sp -4
	sw $t0 0($sp)
	#jal shift_col
	addi $sp $sp 4
	
	move $a0 $v0
	li $v0 1
	#syscall
	

	li $a3 'L'
	li $a0 0xffff0000
	li $a1 4
	li $a2 4
	jal user_move
	move $a0 $v0
	li $v0 1
	syscall
	
	move $a0 $v1 
	li $v0 1
	syscall

# Exit the program
	li $v0, 10
	syscall

###################################################################
# End of MAIN program
####################################################################


#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw4.asm"
