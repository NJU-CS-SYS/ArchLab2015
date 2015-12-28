#ifndef TRAP_H
#define TRAP_H

static __attribute__((noinline)) void good() { while (1); }
static __attribute__((noinline)) void bad() { while (1); }

#define ASSERT(x) do { if (!(x)) bad(); } while (0)

#define set_sp asm volatile("li $sp, 16000");

#endif  // TRAP_H
