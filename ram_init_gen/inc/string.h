#ifndef NPC_STRING_H
#define NPC_STRING_H

#include <sys/types.h>

size_t strlen(const char *s);;

char *strcpy(char *dst, const char *src);

int strcmp(const char *p, const char *q);

void *memset(void *v, int c, size_t n);

void *memmove(void *dst, const void *src, size_t n);

void *memcpy(void *dst, const void *src, size_t n);

#endif
