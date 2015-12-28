.global _reset
.global _qemu
.global good
.global bad

_reset:
  li $sp, 4096
  nop
  j main
  j good

_qemu:
  nop # Make address the same offset
  j main
  j good

good:
$L_GOOD:
  j $L_GOOD

bad:
$L_BAD:
  j $L_BAD
