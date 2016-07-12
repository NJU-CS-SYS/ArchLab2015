.globl _reset
.type _reset, @function

.globl _qemu
.type _qemu, @function

.globl _bad
.type _bad, @function

_reset:
  li $sp, 0xf0000100
  # li $sp, 0x8000
  jal main
$L_GOOD:
  b $L_GOOD

_qemu:
  nop # Make address the same offset
  jal main
$L_LOOP:
  b $L_LOOP

_bad:
$L_BAD:
  b $L_BAD
