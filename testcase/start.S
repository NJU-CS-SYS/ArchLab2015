.global start
.global good
.global bad

start:
  li $sp, 4096
  jal main
  jal good

good:
good_loop:
  j good_loop

bad:
bad_loop:
  j bad_loop
