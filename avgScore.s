.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in 
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0	# $a1 is the size  
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	
	
	# a1 is the len, $v1 is the sum 
	li $v0, 4
	la $a0, str5
	syscall 
	div	$a0, $v1, $a1
    	li 	$v0, 1          	
    	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	# $a0 is the array 
	# $a1 is the len
	
	li 	$t0, 0 		# set $t0 as the counter 
	move 	$t1, $a0 	# set $t1 to the array
		
print_loop:
	beq 	$t0, $a1, print_exit	# return if counter equal to the array len  
	sll 	$t2, $t0, 2		# Multiply the counter by 4 to get the byte offset
	addu 	$t2, $t2, $t1		# set $t2 to the adress of the element 
	lw 	$t2, ($t2) 		# load the content $t2 to itself 
	
	li 	$v0, 1 		# print the element 
	move 	$a0, $t2	
	syscall   
	
	addi 	$t0, $t0, 1
	
	li 	$v0, 11		# print a space 
    	li 	$a0, 32             	
    	syscall
    	j 	print_loop
	
print_exit:
	li 	$v0, 11		# print a new line 
    	li	$a0, 0xA            	
    	syscall
	jr 	$ra 
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	# copy array 
	# $a0 is the len 
	li 	$t0, 0
copy: 
	sll 	$t1, $t0, 2		# Multiply the counter by 4 to get the byte offset
	addu 	$t2, $t1, $s1		# set $t2 to the address of the element 
	addu 	$t3, $t1, $s2 
	lw 	$t4, ($t2) 		# load the content to $t3 
	sw 	$t4, ($t3) 
	addi 	$t0, $t0, 1
    	ble 	$t0, $a0, copy
    	
    	#t0, t1, t2 can not be use later 
    	li	$t0, 0 		# i = 0 
    	addi 	$t1, $a0, -1 	# len - 1 	
selLoop:
	bge 	$t0, $t1, exitSel	# for loop 
	move 	$t2, $t0 		# assume the first element is the greatest and set its index to $t2 
	addi 	$t4, $t0, 1		# j = $t4 = i + 1 
	sel2Loop: 
		bge 	$t4, $a0, endJ
		sll  	$t5, $t4, 2  	# index [j] * 4
		sll  	$t6, $t2, 2 	# index [maxIndex] * 4
		addu 	$t5, $t5, $s2 
		addu 	$t6, $t6, $s2 
		lw 	$t5, ($t5)
		lw	$t6, ($t6) 
			ble 	$t5, $t6, continue # if $t5 is less than $t6 go to continue 
			move 	$t2, $t4  
	continue: 	
		addi 	$t4, $t4, 1
		j 	sel2Loop 
endJ: 	
	sll  	$t3, $t2, 2  	
	addu 	$t4, $t3, $s2	# $t4 = address of sorted[maxindex] 
	lw 	$t5, ($t4) 	# $t5 = value of sorted[maxindex] 
	 
	sll  	$t3, $t0, 2
	addu 	$t6, $t3, $s2   # $t6 = address of sorted[i]
	lw 	$t7, ($t6)	# $t7 = value of sorted[i]
	
	sw	$t7, ($t4) 
	sw 	$t5, ($t6)
	
	addi 	$t0, $t0, 1
	j selLoop

exitSel: 
	jr $ra
	
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	# $a1 is the len number 
	# $a0 is the array 
	bge 	$t8, $a1, exit_cal 
	lw 	$a2, ($a0)  	#load the element into $a2
	add 	$v1, $a2, $v1
	addi 	$a0, $a0, 4	# increment the array pointer
    	addi 	$t8, $t8, 1	# minus the loop counter by 1 
    	j 	calcSum 
exit_cal: 
	jr 	$ra
