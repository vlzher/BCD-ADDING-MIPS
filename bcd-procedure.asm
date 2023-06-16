.macro addBCD()
# input
# a0 - 1 argument
# a1 - 2 argument
# a3 - if last byte 0 - no 1 -yes
# output
# v0 - word
# v1 - overflow
	li $v1, 0
	move $s0, $a0
	move $s1, $a1
	li $t9, 8
	li $v0, 0
	li $s3, 0xf0000000
	li $t7, 0xf
	li $s5, 0
	bnez $a3, notLastByteSum
	
while1BCD:
	li $s7, 28
loop1BCD:
	and $s4, $s0, $s3
	srlv $s4, $s4, $s7
	beq $s4, $t7, endLoop1BCD
	srl $s3, $s3, 4
	subi $s7, $s7, 4
	addi $s5, $s5, 4
	j loop1BCD
endLoop1BCD:
	la $k0, temp
	li $s7, 32
	sub $s7, $s7, $s5
	srlv $s0, $s0, $s7
	srlv $s1, $s1, $s7
	
	sw $s3, 0($k0)
	move $s5, $s7
	
loop2BCD:
notLastByteSum:
	beqz $a3, warunek2
	beqz $t9, endLoop2BCD
warunek2:
	bnez $a3, warunek1
	beqz $s0, warunek3
	j warunek1
warunek3:
	beqz $s1, endLoop2BCD
warunek1:
	li $s6, 16
	div $s0, $s6
	srl $s0, $s0, 4
	mfhi $s4
	bgez $s4, gt1
	add $s4, $s4, 16
gt1:
	div $s1, $s6
	srl $s1, $s1, 4
	mfhi $s7
	bgez $s7, gt2
	add $s7, $s7, 16
gt2:
	add $s7, $s7, $s4
	li $s4, 10
	blt $s7, $s4, addToAnswer
	addi $s7, $s7, 6
	
addToAnswer:
	li $s3, 0xf
	sllv $s3, $s3, $s5
	and $t8, $s3, $v0
	srlv $t8, $t8, $s5
	add $s7, $s7, $t8
	li $s6, 10
	
	blt $s7, $s6, notAddOverflow
	li $s6, 28
	bne $s6, $s5 notAddOverflow
	addi $v1, $zero, 1
notAddOverflow:
	sub $s7, $s7, $t8
	sllv $s7, $s7, $s5
	add $v0, $v0, $s7
	li $s6, 0	
	li $s3, 0xf
correctionLoop:
	beqz $s3, endCorrectionLoop
	and $s7, $v0, $s3
	srlv $s7, $s7, $s6
	beqz $s7, notAddSix
	blt $s7, $s4, notAddSix
	li $s4, 6
	sllv $s4, $s4, $s6
	add $v0, $v0, $s4
notAddSix:
	addi $s6, $s6, 4
	sll $s3, $s3, 4
	j correctionLoop



endCorrectionLoop:
	sub $t9, $t9, 1		
	addi $s5, $s5, 4
	j loop2BCD
endLoop2BCD:
bnez $a3, end_BCD
lw $s1, 0($k0)
or $v0, $s1, $v0
	


	
	
end_BCD:
.end_macro
	 
	




.data
# test 1
#l1: .word 0x4f000000,0,0,0,0,0,0,0
#l2: .word 0x5f000000,0,0,0,0,0,0,0
# test 2
#l1: .word 0x9f000000,0,0,0,0,0,0,0
#l2: .word 0x9f000000,0,0,0,0,0,0,0
# test 2
#l1: .word 0x259f0000,0,0,0,0,0,0,0
#l2: .word 0x35f00000,0,0,0,0,0,0,0
# test 3
#l1: .word 0x99999999,0xf0000000,0,0,0,0,0,0
#l2: .word 0x99999999,0xf0000000,0,0,0,0,0,0
# test 4
#l1: .word   0x89f22226, 0x4f000000, 0x0f000000, 0, 0, 0, 0, 0    
#l2: .word   0x82312332, 0x9f445621, 0x3f000000, 0, 0, 0, 0, 0
# test 5
#l1: .word   0x82312332, 0x9f445621, 0x3f000000, 0, 0, 0, 0, 0
#l2: .word   0x89f22226, 0x4f000000, 0x0f000000, 0, 0, 0, 0, 0
# test 6
#l1:    .word   0x02345678, 0x1f345678, 0x0f000000, 0, 0, 0, 0, 0    
#l2:    .word   0x82312332, 0x2f445621, 0x3f000000, 0, 0, 0, 0, 0    
#test 7
#l1: 0x99999999,0x9999fffd,0,0,0,0,0,0
#l2: 0x99999999,0x9999fffd,0,0,0,0,0,0


l1: 0x9ffffdff,0x10f4f000,0,0,0,0,0,0
l2: 0x9f9fffff,0x474f999f,0,0,0,0,0,0
l3: .word   0x12dddd78, 0xdddddddd, 0xdddddddd, 0xdddddddd, 0xdddddddd, 0xdddddddd, 0xdddddddd, 0xdddddddd      
len1: .word  0
len2: .word  0
lenMax: .word 0
temp: .word 0
      
.text      

main:
      la $t1, l1       
      la $t2, l2       
      la $t3, l3       
      li $s0, 0
      li $s1, 0        

      move $a0, $t1 
      jal  len
      sw   $v0, len1
      
      move $a0, $t2 
      jal  len
      sw   $v0, len2
      li $k1, 0
      jal shiftFuction
      
      jal getMaxLength
      
      jal addNumbers
      
      
      li $v0, 10
      syscall
      
        
      
len:
	move $t0, $a0
	li $t6,0 
	li $s1, 0xf
wordLen:
	li $s6, 0xf0000000
	li $s7, 28
	lw $t7, ($t0)
byteLen:
	move $t8, $t7
	and $t8,$t8,$s6
	srlv $t8, $t8, $s7
	beq $t8,$s1, endLen
	addi $t6, $t6, 1
	subi $s7, $s7, 4
	srl $s6, $s6, 4
	bltz $s7, endByteLen
	j byteLen	
endByteLen:
	 addi $t0, $t0, 4
	 j wordLen	
endLen:
	move $v0, $t6
	jr $ra
	    
shiftFuction:
	bnez $k1, shiftOneTime
	lw $t4, len1
	lw $t5, len2
	
	sub $a0, $t5, $t4
	move $a1, $t1
	
	bgtz $a0, shiftNumber
	
	mul $a0, $a0, -1
	move $a1, $t2
	j shiftNumber
shiftOneTime:
	li $a0, 1	
shiftNumber:
	move $s0, $a1 # adress
	move $s1, $a0 # difference
	
loopS1:		
	beqz $s1, endShift
	move $s4, $s0
	li $s7, 0  # temperal for byte
	li $s2, 8
loopS2:	
	beqz $s2, endLoopS2
	lw $t0, ($s4)
	andi $t6, $t0, 0xf
	sll $t6, $t6, 28
	srl $t0, $t0, 4
	or $t0, $s7, $t0
	sw $t0, ($s4)
	move $s7, $t6
	subi $s2, $s2, 1
	add $s4, $s4, 4
	j loopS2

endLoopS2:
	subi $s1, $s1, 1
	j loopS1
	
endShift:
	jr $ra


getMaxLength:
	lw $t4, len1
	lw $t5, len2
	add $t6, $zero, $t4
	bgt $t4, $t5, goTo1
	add $t6, $zero, $t5
goTo1:
	la $t7, lenMax
	sw $t6, ($t7)
	jr $ra


addNumbers:
	li $t0, 0
	move $t4, $t1 
	move $t5, $t2
	move $t6, $t3
	la $t7, lenMax
	lw $t7 0($t7)
	addi $t8, $zero, 8
	div $t7, $t8
	mfhi $s1
	mflo $s2
	
	sll $s3, $s2, 2
	
	add $t4, $t4, $s3
	add $t5, $t5, $s3
	add $t6, $t6, $s3
	
	
	lw $a0,0($t4)
	lw $a1,0($t5)
	addBCD()
	li $a3, 0
	sw $v0, ($t6)
	beq $t1,$t4 firstByte
	subi $t4, $t4, 4
	subi $t5, $t5, 4
	subi $t6, $t6, 4
	lw $s5, 0($t4)
	add $s5, $s5, $v1
	sw $s5, 0($t4)
	li $a3, 1
	j loopAddByte

loopAddByte:
	beqz $s2, endLoopAddByte
	lw $a0,0($t4)
	lw $a1,0($t5)
	addBCD()
	
	sw $v0, ($t6)
	subi $t4, $t4, 4
	subi $t5, $t5, 4
	subi $t6, $t6, 4
	subi $s2, $s2, 1
	j loopAddByte
endLoopAddByte:
	addi $t4, $t4, 4
	bne $t1,$t4 endFirstByte
	firstByte:
	beqz $v1, endFirstByte	
	li $k1, 1
	move $a1, $t3
	move $k0, $ra 
	jal shiftFuction
	move $ra, $k0
	li $k0, 0
	li $s0 ,1
	sll $s0, $s0, 28
	lw $s1, ($t3)
	add $s1, $s1, $s0
	sw $s1, ($t3)
endFirstByte:
goTo6:
	
	
	
	
	 
	
	
	
endAddNumbers:
	jr $ra
	
	 	 	

	 	
