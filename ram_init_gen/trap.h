#ifndef TRAP_H
#define TRAP_H

void good();
void bad();

#define ASSERT(x) do { if (!(x)) bad(); } while (0)

#define set_sp asm volatile("li $sp, 16000");

#endif  // TRAP_H
