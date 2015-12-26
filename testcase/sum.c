#include "trap.h"

int main() {
    int i = 1, sum = 0;
    while(i <= 100) {
        sum = sum + i;
        i = i + 1;
    }

    ASSERT(sum == 5050);

    good();
    return 0;
}
