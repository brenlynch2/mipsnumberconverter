	.data
menumsg1:	.asciiz "Please select an operation to perform. Input a number from 1-3.\nEntering a non-numerical character WILL cause a crash."
menumsg2:	.asciiz "1. Binary to hexadecimal and decimal"
menumsg3:	.asciiz "2. Hexadecimal to binary and decimal"
menumsg4:	.asciiz "3. Decimal to binary and hexadecimal"
menumsg5:	.asciiz "4. Exit"
option1prompt:	.asciiz "Please enter a binary number. Will accept a maximum of 31 binary bits."
option2prompt:	.asciiz "Please enter a hexadecimal number. Will accept a maximum of 7 characters."
option3prompt:	.asciiz "Please enter a positive decimal(int)number. Entering a character outside of 0-9 WILL cause a crash. \nEntering a number outside int range WILL cause a crash."
binarynummsg: 	.asciiz "Binary number: "
hexnummsg:	.asciiz "Hexadecimal number: "
decimalnummsg:	.asciiz "Decimal number: "
invalidmsg:	.asciiz "You have entered an invalid character. Returning to main menu."
input:		.space 32
newline:	.asciiz "\n"

	.text
main:
	# Brenden Lynch, 2021
	j menu
	
menu:
	#zero out the registers first just in case
	li $t0, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $s0, 0
	
	li $v0, 4
	la $a0, menumsg1
	syscall
	la $a0, newline
	syscall
	la $a0, menumsg2
	syscall
	la $a0, newline
	syscall
	la $a0, menumsg3
	syscall
	la $a0, newline
	syscall
	la $a0, menumsg4
	syscall
	la $a0, newline
	syscall
	la $a0, menumsg5
	syscall
	la $a0, newline
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, 1, invalidinput
	beq $v0, 1, option1
	beq $v0, 2, option2
	beq $v0, 3, option3
	beq $v0, 4, exit
	bgt $v0, 4, invalidinput
	
option1:
	li $v0, 4
	la $a0, option1prompt
	syscall
	li $v0, 8
	la $a0, input
	la $a1, 32 # will accept a maximum 31 characters input
	syscall
	
	la $t0, input
	jal findend
	
	la $t0, input
	add $t0, $t0, -1
	add $t0, $t0, $s1
	li $t4, 0 # used as counter for place value of current number
	
	j binarytodecimal
binarytodecimal:
	lb $t5, 0($t0)
	addi $t0, $t0, -1
	beq $s1, 0, displayresult
	addi $s1, $s1, -1
	beq $t5, 48, add0
	beq $t5, 49, add1
	j invalidinput # if input does not match 0 or 1, terminate
add0:
	addi $s0, $s0, 0
	addi $t4, $t4, 1
	j binarytodecimal
add1:
	li $t6, 1
	sllv $t6, $t6, $t4
	addi $t4, $t4, 1
	add $s0, $s0, $t6
	j binarytodecimal
	
option2:
	li $v0, 4
	la $a0, option2prompt
	syscall
	
	la $a0, newline
	syscall
	
	li $v0, 8
	la $a0, input
	la $a1, 8 #will accept a maximum of 7 characters input
	syscall
	
	la $t0, input
	jal findend
	
	la $t0, input
	addi $t0, $t0, -1
	add $t0, $t0, $s1
	
	li $t4, 0 #place counter
	
	j hextodecimal
hextodecimal:
	lb $t5, 0($t0)
	addi $t0, $t0, -1
	beq $s1, 0, displayresult
	addi $s1, $s1, -1
	blt $t5, 48, invalidinput #if character is less thn 48 in ascii code, invalid input. terminate
	blt $t5, 58, hexnumberprocessor	
	blt $t5, 65, invalidinput #if character is less than 65, then input is invalid, terminate.
	blt $t5, 71, hexuppercaseprocessor
	blt $t5, 97, invalidinput #invalid input, terminate
	blt $t5, 103, hexlowercaseprocessor
	blt $t5, 127, invalidinput #invalid input, terminate
hexnumberprocessor:
	addi $t5, $t5, -48
	sllv $t5, $t5, $t4
	addi $t4, $t4, 4
	add $s0, $s0, $t5
	j hextodecimal
hexuppercaseprocessor:
	addi $t5, $t5, -55
	sllv $t5, $t5, $t4
	addi $t4, $t4, 4
	add $s0, $s0, $t5
	j hextodecimal
hexlowercaseprocessor:
	addi $t5, $t5, -87
	sllv $t5, $t5, $t4
	addi $t4, $t4, 4
	add $s0, $s0, $t5
	j hextodecimal

option3:
	li $v0, 4
	la $a0, option3prompt
	syscall
	
	la $a0, newline
	syscall
	
	li $v0, 5
	syscall
	
	move $s0, $v0
	j displayresult
	
	#common methods below this line
findend:
	# will find where the ascii value '00'(null terminator) or '10'(newline)
	# is in the user entered string. will save the offset to $s1 so the converter methods 
	# can work backwards. this is a result of little endian memory
	lb $t5, 0($t0)
	beq $t5, 0, findendreturn
	beq $t5, 10, findendreturn
	addi $s1, $s1, 1
	addi $t0, $t0, 1
	j findend
findendreturn:
	jr $ra
displayresult:
	# before calling this method, make sure decimal number is in $s0. 
	# will reference $s0 and generate binary and hex values.
	li $v0, 4
	la $a0, newline
	syscall
	
	la $a0, binarynummsg
	syscall
	
	li $v0, 35
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	la $a0, decimalnummsg
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	la $a0, hexnummsg
	syscall
	
	li $v0, 34
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	j menu
invalidinput:
	li $v0, 4
	la $a0, newline
	syscall
	la $a0, invalidmsg
	syscall
	la $a0, newline
	syscall
	j menu
exit:
	li $v0, 10
	syscall
