.text
bad:
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	jal	bad
	nop

good:
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	jal	good
	nop

main:
	addiu	$sp,$sp,-72
	move	$2,$0
	addiu	$7,$sp,24
	sw	$31,68($sp)
	li	$6,2233			# 0x8b9
	li	$5,10			# 0xa
	move	$4,$7
$L6:
	sll	$3,$2,2
	addiu	$4,$4,4
	subu	$3,$6,$3
	addiu	$2,$2,1
	sw	$3,-4($4)
	bne	$2,$5,$L6
	nop

	li	$8,10			# 0xa
	addiu	$6,$sp,60
$L7:
	move	$2,$7
$L9:
	lw	$3,0($2)
	lw	$4,4($2)
	slt	$5,$4,$3
	beq	$5,$0,$L8
	nop

	sw	$4,0($2)
	sw	$3,4($2)
$L8:
	addiu	$2,$2,4
	bne	$6,$2,$L9
	nop

	addiu	$8,$8,-1
	bne	$8,$0,$L7
	nop

	lw	$2,24($sp)
$L12:
	lw	$3,4($7)
	slt	$2,$2,$3
	beq	$2,$0,$L18
	nop

	addiu	$7,$7,4
	move	$2,$3
	bne	$6,$7,$L12
	nop

	jal	good
	nop

$L18:
	jal	bad
	nop

