.global _reset
.global _qemu

_reset:
  li $sp, 4096
  j main
$L_GOOD:
  j $L_GOOD

_qemu:
  nop # Make address the same offset
  jal main
$L_LOOP:
  j $L_LOOP

