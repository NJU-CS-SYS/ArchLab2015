.global _reset
.global _qemu
.global good
.global bad

_reset:
  li $sp, 4096
  jal main
  jal good

_qemu:
  nop # Make address the same offset
  jal main
  jal good

good:
$L_GOOD:
  j $L_GOOD

bad:
$L_BAD:
  j $L_BAD
