#ifndef TRAP_H
#define TRAP_H

#define ASSERT(x) do { \
    if (!(x)) bad();   \
} while (0)

void good();
void bad();

#endif // TRAP_H
