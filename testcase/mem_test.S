.global main

main:
    li $v0, 0xffff0001
    li $v1, 0xffff0002
    li $a0, 0xffff0003
    li $a1, 0xffff0004
    li $a2, 0xffff0005
    li $a3, 0xffff0006

    li $t0, 0x00000000
    li $t1, 0x00000800
    li $t2, 0x00001000
    li $t3, 0x00001800
    li $t4, 0x00002000
    li $t5, 0x00002800

    sw $v0, 0($t0)
    sw $v1, 0($t1)
    sw $a0, 0($t2)
    sw $a1, 0($t3)
    sw $a2, 0($t4)
    sw $a3, 0($t5)

    lw $t0, 0($t0)
    bne $t0, $v0, fuck
    lw $t1, 0($t1)
    bne $t1, $v1, fuck
    lw $t2, 0($t2)
    bne $t2, $a0, fuck
    lw $t3, 0($t3)
    bne $t3, $a1, fuck
    lw $t4, 0($t4)
    bne $t4, $a2, fuck
    lw $t5, 0($t5)
    bne $t5, $a3, fuck

nice:
    li $v0, 89
    li $v1, 0xc0000000
    addiu $v1, 325
    sb $v0, 0(v1)

fuck:
    li $v0, 0xd000f000
    sw $v0,0($v0)
