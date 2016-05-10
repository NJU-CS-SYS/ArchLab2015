.global _reset
.global _qemu

_reset:
  li $sp, 4096
  nop # avoid delay slot optimization
  jal main
$L_GOOD:
  j $L_GOOD

_qemu:
  nop # Make address the same offset
  jal main
$L_LOOP:
  j $L_LOOP
