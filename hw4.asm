
##############################################################
# Homework #4
# name: James_Angeles
# sbuid: 110875002
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

clear_board:
    #Define your code here
	############################################
	
	blt $a1 2 clear_board_error
	blt $a2 2 clear_board_error
		
	li $t0 0 	# row counter
	li $t2 -1 	# value used to store at each 

row_loop:
	
	li $t1 0	# column counter
	
column_loop:
	
	sh  $t2 0($a0)		# store -1 at current index
	addi $t1 $t1 1		# increment column counter 
	addi $a0 $a0 2 		# go to next halfword
	blt $t1 $a2 column_loop	# if didn't reach end of columns, loop
	
column_done:
	addi $t0 $t0 1 		# increment row counter by 1 
	blt $t0 $a1 row_loop	# if not last row, go to next row
	

row_loop_done: 
	jr $ra

	
clear_board_error:
	li $v0 -1
	jr $ra

place:
    #Define your code here
    	 	
	lw $t0 0($sp)		# column num
	lw $t1 4($sp)		# actual column
    	
    
 	addi $sp $sp -28
 	
 	sw $s0 0($sp) 		# store board address at $s0
 	sw $s1 4($sp)
 	sw $s2 8($sp)
 	sw $s3 12($sp)
 	sw $s4 16($sp)
 	sw $s5 20($sp)
 	sw $ra 24($sp)
 	
 	move $s0 $a0 		# store arguments in corresponding s registers
 	move $s1 $a1
 	move $s2 $a2
 	move $s3 $a3
 	move $s4 $t0
 	move $s5 $t1
 	
 	blt $s1 2 place_error		# throw error if n_row < 2
 	blt $s2 2 place_error		# throw error if n_col < 2
 	bltz $s3 place_error		# throw error if row < 0
 	bge $s3 $s1 place_error		# throw error if row > n_row - 1
 	bltz $s4 place_error		# throw error if col < 0
 	bge $s4 $s2 place_error 	# throw error if col > n_col - 1 
 	
 	beq $s5 -1 place_val		# if val == -1, ignore power check and actually place value
 	move $a0 $s5
 	jal count_ones
 	bne $v0 1 place_error
 	

place_val: 	
	li $t0 2 		# elem_size_in_bytes
	mul $t1 $s3 $s2		# i * num_columns
	add $t1 $t1 $s4	# (i * num_columns + j)
	mul $t2 $t0 $t1		# elem_size_in_bytes * (i * num_columns + j)
	
	add $t3 $s0 $t2		# base_address +  elem_size_in_bytes * (i * num_columns + j)
	
	sh $s5 0($t3)		# store value at desired address
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $ra 24($sp)		# restore all preserved registers
	addi $sp $sp 28
	
	li $v0 0
    	jr $ra
    	
place_error: 

	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $ra 24($sp)		# restore all registers
	addi $sp $sp 28

	li $v0 -1 		# return -1 for error
	jr $ra
    
    

count_ones: 
	 move $t0 $a0		# set $t0 to value being checked
	 li $t1 0		# counter = 0
	 li $t2 1 		# position = 1
	 li $t3 0		# i = 0 
	 
	 
ones_loop: 
	and $t4 $t0 $t2		# & value and position
	beqz $t4 end_if		# if there is no one at that position, continue to next part and do not add 1
	addi $t1 $t1 1 		# if there is a one at that position, increment counter by 1
	
end_if: 
	sll $t2 $t2 1		# position = position << 1
	addi $t3 $t3 1		# i++
	blt $t3 32 ones_loop	# if i < 32, loop 
	
ones_done:

	move $v0 $t1		# move counter into return value
	jr $ra	  		# jump back
		
	

start_game:
    #Define your code here
	############################################
	lw $t0 0($sp)		# t0 = c1
	lw $t1 4($sp)		# t1 = r2
	lw $t2 8($sp)		# t2 = c2
	
	addi $sp $sp -32
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)		#preserve  registers
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $s5 20($sp)
	sw $s6 24($sp)
	sw $ra 28($sp)
	
	move $s0 $a0		# s0 = board
	move $s1 $a1		# s1 = num_rows
	move $s2 $a2		# s2 = num_col
	move $s3 $a3		# s3 = r1
	move $s4 $t0		# s4 = c1
	move $s5 $t1		# s5 = r2
	move $s6 $t2		# s6 = c2
	
	
	jal clear_board		
	beq $v0 -1 start_game_error
	
	li $t0 2
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	move $a3 $s3
	addi $sp $sp -8
	sw $s4 0($sp)			# store $c1 and val onto stack for place to retrieve
	sw $t0 4($sp)
	
	jal place
	lw $t0 4($sp)			# load back val into $t0
	addi $sp $sp 8			# deallocate stack space
	beq $v0 -1 start_game_error	# if place returned error, throw error
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	move $a3 $s5		# set a3 to r2
	addi $sp $sp -8
	sw $s6 0($sp)		# set a4 to c2
	sw $t0 4($sp)		# set a5 to val
	
	jal place
	lw $t0 4($sp)		# load back val into $t0
	addi $sp $sp 8		# deallocate stack space
	beq $v0 -1 start_game_error	# if place returned error, throw error
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)		# restore  registers
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $ra 28($sp)
	addi $sp $sp 32
	li $v0 0
	jr $ra
	
start_game_error:

	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)		# restore  registers
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $ra 28($sp)
	addi $sp $sp 32
	li $v0 -1 
	jr $ra


##############################
# PART 2 FUNCTIONS
##############################

merge_row:
    
    lw $t0 0($sp)		#set $t0 to direction
    
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s0 4($sp)
    
    move $s0 $a1
    
    bltz $a3 merge_row_error	# if row is negative, throw error
    bge $a3 $a1 merge_row_error # if row is greater than or equal to num of rows
    blt $a1 2 merge_row_error	# if num_rows is less than 2, throw error
    blt $a2 2 merge_row_error	# if num_columns is less than 2, throw error
    beqz $t0 findBeginningAddress	# if direction equals 0, no need to go thru next check
    bne $t0 1 merge_row_error	# if direction dne 0 or 1, throw error
    
    
    
findEndingAddress:

	li $t1 2
	mul $t2 $a3 $a2			# set $t2 to (i * num_columns)
	addi $t0 $a2 -1			# get j (last column -1 )
	add $t2 $t2 $t0			# (i * num_columns + j)
	mul $t2 $t2 $t1			# elem_size_in_bytes * (i * num_columns + j)
	move $t3 $t0			# column counter
	add $t0 $a0 $t2			# base_address + elem_size_in_bytes * (i * num_columns + j)
	li $t7 0			# num of empty cells
	
	
	
merge_right:
	
	beqz $t3 check_first_empty
	
	lh $t5 0($t0)			# load value at current column
	addi $t0 $t0 -2			# go back to adjacent column's address in order to retrieve value
	lh $t6 0($t0)			# load value at adjacent column
	
	addi $t3 $t3 -1			# go to next column (adjacent)	
	
	beq $t5 -1 increment_empty_cells_right
	bne $t5 $t6 merge_right
	
	sll $t5 $t5 1			# shift left by 1 bit (multiply by 1)
	li $t6 -1			# set $t6 to -1 
	sh $t5 2($t0)
	sh $t6 0($t0)
	
	j merge_right
	
	
increment_empty_cells_right:
	addi $t7 $t7 1 
	j merge_right
	
check_last_empty:
	move $a1 $a3
	addi $a3 $a2 -1
	jal getSelectedAddress
	move $t0 $v0
	lh $t1 0($t0)
	
	bne $t1 -1 merge_done
	addi $t7 $t7 1 
	j merge_done
	
	
	

    
findBeginningAddress:

	li $t1 2			# elem_size_in_bytes
    	mul $t2 $a3 $a2			# set $t2 to (i * num_columns)
    	mul $t2 $t1 $t2			# elem_size_in_bytes * (i * num_columns)
    	add $t0 $a0 $t2		# base_address + elem_size_in_bytes * (i * num_columns) == ending address
    	li $t3 0 			# column counter
    	addi $t4 $a2 -1			# want to stop at last element bc no need to compare
    	li $t7 0			# numOfMerges (num of -1s)
    	
merge_left:
	beq $t3 $t4 check_last_empty
	
	lh $t5 0($t0)		# load value at current column
	lh $t6 2($t0)		# load value at the adjacent column (right)
	
	addi $t0 $t0 2		# increment address
	addi $t3 $t3 1		# increment column counter
	
	beq $t5 -1  increment_empty_cells_left
	bne $t5 $t6 merge_left
	
	addi $t0 $t0 -2 	# used to go back to current address
	sll $t5 $t5 1		# shift left one bit to multiply by 2
	li $t6 -1		# set adjacent column value to -1
	
	sh $t5 0($t0)
	sh $t6 2($t0)
	
	addi $t0 $t0 2		# go to next address
	
	j merge_left
	
increment_empty_cells_left:
	addi $t7 $t7 1
	j merge_left
	
check_first_empty:
	
	move $a1 $a3
	li $a3 0
	jal getSelectedAddress
	move $t0 $v0
	lh $t1 0($t0)
	bne $t1 -1 merge_done
	addi $t7 $t7 1
	
merge_done: 
	sub $v0 $s0 $t7
	lw $ra 0($sp)
	lw $s0 4($sp)
	addi $sp $sp 8
	jr $ra
	
	
merge_row_error:
	li $v0 -1
	lw $ra 0($sp)
	lw $s0 4($sp)
	addi $sp $sp 8
	jr $ra
	
    	


merge_col:

	lw $t0 0($sp)			# set $t0 to direction

	addi $sp $sp -12
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $ra 8($sp)

	
    	bltz $a3 merge_col_error	# if col is negative, throw error
    	bge $a3 $a2 merge_col_error 	# if col is greater than or equal to num of col
    	blt $a1 2 merge_col_error	# if num_rows is less than 2, throw error
    	blt $a2 2 merge_col_error	# if num_columns is less than 2, throw error
    	
    	move $t1 $a0			# set $t1 to board address
	li $t2 0			# set t2 to num of merges
	li $t3 0			# set t3 to row counter
	addi $t4 $a1 -1			# set t4 to last row element
    	
    	beqz $t0 merge_top	# if direction equals 0, no need to go thru next check
    	bne $t0 1 merge_col_error	# if direction dne 0 or 1, throw error
    	
    	
    	
merge_bottom: 
	beqz $t4 check_first_cell_col
	
	    	
	mul $t5 $t4 $a2			# i * num_of_columns
	add $t5 $t5 $a3			# i * num_of_columns + j
	sll $t5 $t5 1			# (i * num_of_columns + j) * 2 (shift left by 1 bit = multiply by 2)
	add $t5 $t5 $t1			# adds base address to result giving desired address
	
	move $s0 $t5			# sets 0 to current row address
	
	lh $t6 0($s0)			# stores current row value into $t6
	
	addi $t4 $t4 -1			# goes to next row
	mul $t5 $t4 $a2			# i * num_of_columns
	add $t5 $t5 $a3			# i * num_of_columns + j
	sll $t5 $t5 1
	add $t5 $t5 $t1			# gets next row element address
	
	move $s1 $t5			# sets s1 to adjacent row address

	lh $t7 0($s1)
	
	beq $t6 -1 increment_empty_cells_col_bottom
	bne $t6 $t7 merge_bottom	# if two values aren't equal go to next set of values
	
	sll $t6 $t6 1			# multiply current val by 2
	sh $t6 0($s0)			# store value into current address
	
	li $t7 -1
	sh $t7 0($s1)			# store -1 into adjacent address

	
	j merge_bottom
	
	    	
increment_empty_cells_col_bottom:
	addi $t2 $t2 1
	j merge_bottom
	

check_first_cell_col:     	
	li $a1 0
	jal getSelectedAddress
	move $t0 $v0
	lh $t1 0($t0)
	bne $t1 -1 merge_col_done
	addi $t2 $t2 1
	j merge_col_done
    	
merge_top:
	beq $t3 $t4 check_last_cell_col
	
	mul $t5 $t3 $a2			# i * num_of_columns
	add $t5 $t5 $a3			# i * num_of_columns + j
	sll $t5 $t5 1			# (i * num_of_columns + j) * 2 (shift left by 1 bit = multiply by 2)
	add $t5 $t5 $t1			# adds base address to result giving desired address
	
	move $s0 $t5			# sets 0 to current row address
	
	lh $t6 0($s0)			# stores current row value into $t6
	
	addi $t3 $t3 1			# goes to next row
	mul $t5 $t3 $a2			# i * num_of_columns
	add $t5 $t5 $a3			# i * num_of_columns + j
	sll $t5 $t5 1
	add $t5 $t5 $t1			# gets next row element address
	
	move $s1 $t5			# sets s1 to adjacent row address

	lh $t7 0($s1)
	
	beq $t6 -1 increment_empty_cells_col_top
	bne $t6 $t7 merge_top		# if two values aren't equal go to next set of values
	
	sll $t6 $t6 1			# multiply current val by 2
	sh $t6 0($s0)			# store value into current address
	
	li $t7 -1
	sh $t7 0($s1)			# store -1 into adjacent address
	
	j merge_top
	
	
	
increment_empty_cells_col_top:
	addi $t2 $t2 1
	j merge_top
	
check_last_cell_col:
	addi $a1 $a1 -1
	jal getSelectedAddress
	move $t0 $v0
	lh $t1 0($t0)
	bne $t1 -1 merge_col_done
	addi $t2 $t2 1
	j merge_col_done
	

merge_col_done:
	sub $v0 $a2 $t2 
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $ra 8($sp)
	addi $sp $sp 12
	jr $ra
    	
    	
    	
merge_col_error:
	li $v0 -1
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $ra 8($sp)
	addi $sp $sp 12
	jr $ra

shift_row:
    	lw $t0 0($sp)		# $t0 = direction
    	
    	addi $sp $sp -24	
    	sw $s0 0($sp)
    	sw $s1 4($sp)
    	sw $s2 8($sp)
    	sw $s3 12($sp)
    	sw $s4 16($sp)
    	sw $ra 20($sp)		# preserve s registers
    	
    	
    	move $s0 $a0
    	move $s1 $a1
    	move $s2 $a2
    	move $s3 $a3
    	move $s4 $t0		# move arguments into corresponding s registers
    	
    	
    	
    
    	bltz $s3 shift_row_error		# if row < 0, throw error
    	bge $s3 $s1 shift_row_error		# if row > num_row -1, throw error
    	blt $s1 2 shift_row_error		# if num_row < 2, throw error
    	blt $s2 2 shift_row_error		# if num_col < 2, throw error
    	beqz $s4 shift_row_left			# if direction == 0, ignore error check -> already passed
    	bne $s4 1 shift_row_error		# if direction != 0 or 1 , throw error
    	
    	
shift_row_right:
	li $t0 0			#shift counter
	addi $t1 $s2 -1			# current column counter (j)
	li $t3 0			# current column value (board[i][j])
	li $t4 0 			# shift target value (board[i][k]
	li $t8 -1			# empty square
	
shift_row_right_outer:
	beqz $t1 shift_row_done
	
	move $a0 $s0			# set $a0 to base address			
	move $a1 $s3			# set $a1 to i (row)
	move $a2 $s2			# set $a2 to num_col
	move $a3 $t1			# set $a3 to j (current col value)
	jal getSelectedAddress
	move $t6 $v0
	
	lh $t3 0($t6)
	addi $t2 $t1 -1			# shift target counter (k)
	addi $t1 $t1 -1			# increment j by 1
	bne $t3 -1 shift_row_right_outer
	
	 
shift_row_right_inner:
	bltz $t2 shift_row_right_outer
	
	move $a3 $t2			# set $a3 to k (shift target col)
	jal getSelectedAddress
	move $t7 $v0			# store desired address in $t7
	
	lh $t4 0($t7)			# load target half word into $t4 
	addi $t2 $t2 -1			# go to next column
	beq $t4 -1 shift_row_right_inner	# if $t4 == -1, go to next iteration
	
	sh $t4 0($t6)			# store target column value into current column
	sh $t8 0($t7)			# store -1 into target column
	addi $t0 $t0 1 			# increment num of shifts by 1
	j shift_row_right_outer		# go back to outer loop
	
	


shift_row_left:
	li $t0 0			#shift counter
	li $t1 0			# current column counter (j)
	li $t3 0			# current column value (board[i][j])
	li $t4 0 			# shift target value (board[i][k]
	addi $t5 $s2 -1			# num_col -1
	li $t8 -1			# empty square 
	
	
shift_row_left_outer:
	beq $t1 $t5 shift_row_done
	
	move $a0 $s0			# set $a0 to base address			
	move $a1 $s3			# set $a1 to i (row)
	move $a2 $s2			# set $a2 to num_col
	move $a3 $t1			# set $a3 to j (current col value)
	jal getSelectedAddress
	move $t6 $v0			# store desired address in $t6
	
	lh $t3 0($t6)			# get value at current column
	addi $t2 $t1 1			# shift target counter (k)
	addi $t1 $t1 1			# increment j by 1 
	bne $t3 -1 shift_row_left_outer
	
	
shift_row_left_inner:
	beq $t2 $s2 shift_row_left_outer
	
	move $a3 $t2			# set $a3 to k (shift target col)
	jal getSelectedAddress
	move $t7 $v0			# store desired address in $t7
	
	lh $t4 0($t7)
	addi $t2 $t2 1			# increment k counter by 1
	beq $t4 -1 shift_row_left_inner
	
	sh $t4 0($t6)			# store board[i][k] at board[i][j]
	sh $t8 0($t7)			# store -1 at shift target address
	addi $t0 $t0 1 			# increment num of shifts by 1
	j shift_row_left_outer
	
	

shift_row_done:

	move $v0 $t0 
    	
    	lw $s0 0($sp)
    	lw $s1 4($sp)
    	lw $s2 8($sp)
    	lw $s3 12($sp)
    	lw $s4 16($sp)
    	lw $ra 20($sp)		# preserve s registers
    	addi $sp $sp 24
    	
    	jr $ra
    	
shift_row_error:
	li $v0 -1
    	
    	lw $s0 0($sp)
    	lw $s1 4($sp)
    	lw $s2 8($sp)
    	lw $s3 12($sp)
    	lw $s4 16($sp)
    	lw $ra 20($sp)		# preserve s registers
    	addi $sp $sp 24
    	
    	jr $ra	
    	
    	
    	

shift_col:

	lw $t0 0($sp)		# $t0 = direction
    	
    	addi $sp $sp -24	
    	sw $s0 0($sp)
    	sw $s1 4($sp)
    	sw $s2 8($sp)
    	sw $s3 12($sp)
    	sw $s4 16($sp)
    	sw $ra 20($sp)		# preserve s registers
    	
    	
    	move $s0 $a0
    	move $s1 $a1
    	move $s2 $a2
    	move $s3 $a3
    	move $s4 $t0		# move arguments into corresponding s registers
    	
    	
    	bltz $s3 shift_col_error		# if row < 0, throw error
    	bge $s3 $s2 shift_col_error		# if row > num_row -1, throw error
    	blt $s1 2 shift_col_error		# if num_row < 2, throw error
    	blt $s2 2 shift_col_error		# if num_col < 2, throw error
    	beqz $s4 shift_col_up			# if direction == 0, ignore error check -> already passed
    	bne $s4 1 shift_col_error		# if direction != 0 or 1 , throw error
    	
shift_col_bottom:

	li $t0 0			#shift counter
	addi $t1 $s1 -1 		# current row counter (i)
	li $t3 0			# current row value (board[i][k])
	li $t4 0 			# shift target value (board[j][k]
	li $t8 -1			# empty square 


shift_col_bottom_outer:
	beqz $t1 shift_col_done
	
	move $a0 $s0
	move $a1 $t1
	move $a2 $s2
	move $a3 $s3
	jal getSelectedAddress
	move $t6 $v0
	lh $t3 0($t6)
	addi $t2 $t1 -1
	addi $t1 $t1 -1
	bne $t3 -1 shift_col_bottom_outer
	
shift_col_bottom_inner:

	bltz $t2 shift_col_bottom_outer
	move $a1 $t2
	jal getSelectedAddress
	move $t7 $v0
	lh $t4 0($t7)
	addi $t2 $t2 -1 
	beq $t4 -1 shift_col_bottom_inner
	
	sh $t4 0($t6)
	sh $t8 0($t7)
	addi $t0 $t0 1 
	
	j shift_col_bottom_outer
	
	

shift_col_up:

	li $t0 0			#shift counter
	li $t1 0			# current row counter (i)
	li $t3 0			# current row value (board[i][k])
	li $t4 0 			# shift target value (board[j][k]
	addi $t5 $s1 -1			# num_row -1
	li $t8 -1			# empty square 

shift_col_up_outer:
	beq $t1 $t5 shift_col_done
	move $a0 $s0			# set $a0 to base address			
	move $a1 $t1			# set $a1 to i (row)
	move $a2 $s2			# set $a2 to num_col
	move $a3 $s3			# set $a3 to j (current col value)
	jal getSelectedAddress
	
	move $t6 $v0
	lh $t3 0($t6)
	addi $t2 $t1 1
	addi $t1 $t1 1 
	bne $t3 -1 shift_col_up_outer


shift_col_up_inner:
	beq $t2 $s1 shift_col_up_outer
	
	move $a1 $t2
	jal getSelectedAddress
	move $t7 $v0
	lh $t4 0($t7)
	
	addi $t2 $t2 1 
	beq $t4 -1 shift_col_up_inner
	
	sh $t4 0($t6)
	sh $t8 0($t7)
	addi $t0 $t0 1 
	
	j shift_col_up_outer
	
	
shift_col_done: 
	move $v0 $t0 

    	lw $s0 0($sp)
    	lw $s1 4($sp)
    	lw $s2 8($sp)
    	lw $s3 12($sp)
    	lw $s4 16($sp)
    	lw $ra 20($sp)		# preserve s registers
    	addi $sp $sp 24
    	
    	jr $ra
    	
shift_col_error:

	li $v0 -1
    	
    	lw $s0 0($sp)
    	lw $s1 4($sp)
    	lw $s2 8($sp)
    	lw $s3 12($sp)
    	lw $s4 16($sp)
    	lw $ra 20($sp)		# preserve s registers
    	addi $sp $sp 24
    	
    	jr $ra


check_state:

	addi $sp $sp -16
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $ra 12($sp)
	
	move $s0 $a0		# s0 = board
	move $s1 $a1		# s1 = num_rows
	move $s2 $a2		# s2 = num_cols
	
	move $a0 $s0 		# base_addr
	addi $a1 $s1 -1		#  num_rows -1 to get last row
	move $a2 $s2		# num_cols
	addi $a3 $s2 -1 	# num_cols -1 to get last column
	
	jal getSelectedAddress
	move $t0 $v0 		# get last board position
	li $t1 0		# num of cells occupied counter
	move $t4 $s0
    
board_loop:
	bgt $t4 $t0 count_full_cells
	
	lh $t2 0($t4)		
	bge $t2 2048 win	# if one of the cells contain 2048, returns a win
	addi $t4 $t4 2		# increment board address
	beq $t2 -1 board_loop 	# if the value of cell in $t2 is empty, go to next cell
	addi $t1 $t1 1		# increment num of cells occupied counter
	j board_loop 
	
	
count_full_cells:
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2 
	mul $t3 $s1 $s2		# get max amount of cells in board
	bne $t1 $t3 continue	# if the num of occupied != max amount, return that user can continue game
	jal check_merge		# check if any cells can be merged
	beq $v0 -1 lost		# if not, the user has lost the game

continue:
	li $v0 0
	j return_result
lost: 
	li $v0 -1
	j return_result
	
win: 
	li $v0 1
	j return_result
	
return_result:
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $ra 12($sp)
	addi $sp $sp 16	
	jr $ra
	
	
#$a0 = board
#$a1 = num_rows
#$a2 = num_cols
	
check_merge:
	
	addi $sp $sp -16
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $ra 12($sp)		# preserve existing s registers
		
	move $s0 $a0		# move a registers into corresponding s registers	
	move $s1 $a1
	move $s2 $a2
	move $s3 $a3
	li $t0 0		# row counter
	li $t1 0		# column loop
	addi $t2 $s2 -1		# num_col -1 (used for branch)
	
check_row_outer:
	beq $t0 $s1 zero_out
	
	li $t1 0		# resets column counter back to 0
	move $a0 $s0		
	move $a1 $t0 
	move $a2 $s2
	li $a3 0
	jal getSelectedAddress
	move $t3 $v0		# sets $t3 to board[a1][[0]
	addi $t0 $t0 1		# increment row counter by 1  

check_row_inner:
	beq $t1 $t2 check_row_outer	# if column counter == last column, go back to outer loop
	
	lh $t4 0($t3)			# loads value from board[a1][$t3]
	
	addi $t1 $t1 1 			# increment column counter by 1 before checking condition
	addi $t3 $t3 2
	beq $t4 -1 check_row_inner	# if ther is no value at board[a1][$t3], go to next column
	
	lh $t5 0($t3)			# gets adjacent value
	
	beq $t4 $t5 is_merge		# if there is a merge available, quit both loops and return that it can be merged
	
	j check_row_inner
	

		
zero_out:
	li $t0 0		# column counter
	li $t1 0		# row counter
	addi $t2 $s2 -1		# num_col -1 (used for branch)
	


check_merge_col_outer:
	beq $t0 $t2 no_merge
	
	addi $t0 $t0 1		# increments current column counter
	li $t1 0		# resets row counter   

check_merge_col_inner:
	beq $t1 $s1 check_merge_col_outer	# if current row == last row, go to next column
	
	move $a0 $s0		# moves board address into $a0
	move $a1 $t1		# sets i to be $t1, bc want to start at the $t1th row
	move $a2 $s2		# moves num_cols into $a2
	move $a3 $t0		# sets j to to the current column being checked
	jal getSelectedAddress
	move $t3 $v0		# sets $t3 to board[0][$t0]
	lh $t4 0($t3)
	addi $t1 $t1 1
	beq $t4 -1 check_merge_col_inner	# if there is no value at board [$t0][$t1]
	
	move $a1 $t1				# get board @ [$t0 + 1][$t1] address
	jal getSelectedAddress
	
	lh $t5 0($v0)				# load next adjacent row's value
	beq $t4 $t5 is_merge			# if they can be merged, return that it can be merged
	
	j check_merge_col_inner			# if not continue loop
	
	
is_merge:

	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $ra 12($sp)		# preserve existing s registers
	addi $sp $sp 16
	li $v0 0
	jr $ra
	
	
no_merge:
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $ra 12($sp)		# preserve existing s registers
	addi $sp $sp 16
	li $v0 -1
	jr $ra
	


user_move:
    	addi $sp $sp -24
    	sw $s0 0($sp)
    	sw $s1 4($sp)
    	sw $s2 8($sp)
    	sw $s3 12($sp)
    	sw $s4 16($sp)
    	sw $ra 20($sp)
    	
    	move $s0 $a0 
    	move $s1 $a1
    	move $s2 $a2
    	move $s3 $a3
    	li $s4 0		# initializes row/counter counter
    	
    	beq $s3 0x4C load_horizontal_left		# if input is 'L', complete left user move
    	beq $s3 0x52 load_horizontal_right		# if input is 'R', complete right user move
    	beq $s3 0x55 load_vertical_top			# if input is 'U', complete up user move
    	beq $s3 0x44 load_vertical_bottom		# if input is 'D', complete down user move
    	
    	j move_error
    	
 
    	
load_horizontal_left:
	li $t1 0
 	j user_horizontal_shift
 	
load_horizontal_right:
	li $t1 1
	j user_horizontal_shift
  	   	   	   	
    	   	   	   	   	   	
user_horizontal_shift:
	beq $s4 $s1 zero_horizontal
	
	move $a0 $s0 			# set $a0 to cell[][]board
	move $a1 $s1			# set $a1 to num_rows
	move $a2 $s2			# set $a2 to num_cols
	move $a3 $s4			# set $a3 to row number
	addi $sp $sp -4
	sw $t1 0($sp)			# put fourth argument direction on stack
	jal shift_row
	beq $v0 -1 move_error
	lw $t1 0($sp)
	addi $sp $sp 4
	addi $s4 $s4 1
	
	j user_horizontal_shift
	
zero_horizontal: 
	li $s4 0

user_horizontal_merge:
	beq $s4 $s1 zero_horizontal_one_more
	
	move $a0 $s0			# cell[][] board
	move $a1 $s1			# num_rows
	move $a2 $s2			# num_cols
	move $a3 $s4			# current row 
	addi $sp $sp -4
	sw $t1 0($sp)			# store direction on stack
	jal merge_row
	beq $v0 -1 move_error
	lw $t1 0($sp)			# deallocate stack
	addi $sp $sp 4			
	addi $s4 $s4 1 			# increment row counter
	j user_horizontal_merge  




zero_horizontal_one_more: 
	li $s4 0
	j  user_horizontal_shift_one_more


user_horizontal_shift_one_more:
	beq $s4 $s1 check_board
	
	move $a0 $s0 			# set $a0 to cell[][]board
	move $a1 $s1			# set $a1 to num_rows
	move $a2 $s2			# set $a2 to num_cols
	move $a3 $s4			# set $a3 to row number
	addi $sp $sp -4
	sw $t1 0($sp)			# put fourth argument direction on stack
	jal shift_row
	beq $v0 -1 move_error
	lw $t1 0($sp)
	addi $sp $sp 4
	addi $s4 $s4 1
	
	j user_horizontal_shift_one_more
	
load_vertical_top:
	li $t1 0
	j user_vertical_shift

load_vertical_bottom:
	li $t1 1
	j user_vertical_shift
	
user_vertical_shift:
	beq $s4 $s2 zero_vertical	# if finished shifting all columns, go to merge
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	move $a3 $s4			# move appropiate values into appropiate argument registers
	addi $sp $sp -4
	sw $t1 0($sp)			# store direction onto stack for shift_col to retrieve
	jal shift_col
	beq $v0 -1 move_error
	lw $t1 0($sp)			# load back direction and deallocate stack
	addi $sp $sp 4			
	addi $s4 $s4 1 			# increment column counter by 1
	j user_vertical_shift
	
zero_vertical:
	li $s4 0 
	j user_vertical_merge
	
user_vertical_merge:

	beq $s4 $s2 zero_vertical_one_more
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	move $a3 $s4
	addi $sp $sp -4
	sw $t1 0($sp)
	jal merge_col
	beq $v0 -1 move_error
	lw $t1 0($sp)
	addi $sp $sp 4
	addi $s4 $s4 1
	j user_vertical_merge
	
zero_vertical_one_more:
	li $s4 0 
	j user_vertical_shift_one_more
	

user_vertical_shift_one_more:
	beq $s4 $s2 check_board 	# if finished shifting all columns, go to merge
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	move $a3 $s4			# move appropiate values into appropiate argument registers
	addi $sp $sp -4
	sw $t1 0($sp)			# store direction onto stack for shift_col to retrieve
	jal shift_col
	beq $v0 -1 move_error
	lw $t1 0($sp)			# load back direction and deallocate stack
	addi $sp $sp 4			
	addi $s4 $s4 1 			# increment column counter by 1
	j user_vertical_shift_one_more
	
	
check_board:

	move $a0 $s0
	move $a1 $s1
	move $a2 $s2
	jal check_state
	move $v1 $v0
	li $v0 0
	j return_move	
    	
move_error:
	li $v0 -1
	li $v1 -1
    	j return_move
    	  	  	
return_move: 	

	lw $s0 0($sp)
	lw $s1 4($sp)
    	lw $s2 8($sp)
    	lw $s3 12($sp)
    	lw $s4 16($sp)
    	lw $ra 20($sp)
    	addi $sp $sp 24
    	jr $ra
    

getSelectedAddress:
	addi $sp $sp -4
	sw $s0 0($sp)
	
	mul $s0 $a1 $a2			# i * num_columns
	add $s0 $s0 $a3		# i * num_columns + j
	sll $s0 $s0 1			# multiply by 2
	add $s0 $s0 $a0		# add base address to it
	
	move $v0 $s0 			# set return value to desired address
	
	
	lw $s0 0($sp)
	addi $sp $sp 4
	jr $ra
	
	

#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

#place all data declarations here


