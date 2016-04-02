int qsort(int A[], int m, int n)
{
    int i, j;
    int v, x;
    if (n <= m) return 0;

    i = m-1; j = n; v = A[n];
    while (1) {
        i = i + 1; while (A[i] < v) i = i + 1;
        j = j - 1; while (A[j] > v) j = j - 1;

        if (i >= j) {
            x = A[i]; A[i] = A[n]; A[n] = x;
            qsort(A, m, j); qsort(A, i + 1, n);
            return 0;
        }

        x = A[i]; A[i] = A[j]; A[j] = x;
    }

    return 0;
}

#include "trap.h"

int main()
{
    int a[5];

    a[0] = 3;
    a[1] = 4;
    a[2] = 2;
    a[3] = 1;
    a[4] = 0;

    qsort(a, 0, 4);

    ASSERT(a[0] == 0);
    ASSERT(a[1] == 1);
    ASSERT(a[2] == 2);
    ASSERT(a[3] == 3);
    ASSERT(a[4] == 4);

    good();
    return 0;
}
