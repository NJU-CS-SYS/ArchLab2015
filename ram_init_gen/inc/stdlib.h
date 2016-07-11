#ifndef NPC_STDLIB_H
#define NPC_STDLIB_H

int atoi(const char *nptr);

char *strtok(char *string_org, const char* demial);

long strtol(char *nptr, char  **endptr, int  base);

unsigned int rand();

#endif
