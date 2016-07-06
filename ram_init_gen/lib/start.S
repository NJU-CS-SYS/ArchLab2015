.global _reset
.global _qemu
.global do_irq

_reset:
  li $sp, 0xf0008000
  # li $sp, 0x8000
  jal main
$L_GOOD:
  b $L_GOOD

_qemu:
  nop # Make address the same offset
  jal main
$L_LOOP:
  b $L_LOOP

.extern irq_handle

do_irq:
  jal irq_handle
  eret
