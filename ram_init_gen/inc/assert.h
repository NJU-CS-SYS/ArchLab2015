#ifndef NPC_ASSERT_H
#define NPC_ASSERT_H

#include <stdio.h>

extern void _bad(void);

#define S(x) #x
#define assert(x) \
    do { \
        if (!(x)) { puts("Assertion failed: " S(x)); _bad(); } \
    } while (0)

#endif
