#include"./trap.h"

#define N 10
int main() {
    int a[N];
    int i = 0;
    while(i < N) {
        a[i] = 2233 - (i << 2);
        i = i + 1;
    }

    int t;
    int j=0;
    while(j < N) {
        i = 0;
        while(i < N - 1) {
            if(a[i] > a[i + 1]) {
                t = a[i];
                a[i] = a[i + 1];
                a[i + 1] = t;
            }
            i = i + 1;
        }
        j = j + 1;
    }


    for (i = 0; i < N-1; i++) {
        if (a[i] >= a[i + 1]) bad();
    }
    good();
    return 0;
}
