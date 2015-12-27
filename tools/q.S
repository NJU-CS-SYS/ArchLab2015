	.file	1 "bubble-sort.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.gnu_attribute 4, 3
	.abicalls
	.text
	.align	2
	.set	nomips16
	.set	nomicromips
	.ent	bad
	.type	bad, @function
bad:
	.frame	$sp,32,$31		# vars= 0, regs= 1/0, args= 16, gp= 8
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	.option	pic0
	jal	bad
	nop

	.option	pic2
	.set	macro
	.set	reorder
	.end	bad
	.size	bad, .-bad
	.align	2
	.set	nomips16
	.set	nomicromips
	.ent	good
	.type	good, @function
good:
	.frame	$sp,32,$31		# vars= 0, regs= 1/0, args= 16, gp= 8
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	.option	pic0
	jal	good
	nop

	.option	pic2
	.set	macro
	.set	reorder
	.end	good
	.size	good, .-good
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,72,$31		# vars= 40, regs= 1/0, args= 16, gp= 8
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
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

	.option	pic0
	jal	good
	nop

	.option	pic2
$L18:
	.option	pic0
	jal	bad
	nop

	.option	pic2
	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Buildroot 2015.08.1) 4.9.3"
