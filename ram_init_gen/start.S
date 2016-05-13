.global _reset
.global _qemu

_reset:
  li $sp, 4096
  jal main
$L_GOOD:
  b $L_GOOD

_qemu:
  nop # Make address the same offset
  jal main
$L_LOOP:
  b $L_LOOP
