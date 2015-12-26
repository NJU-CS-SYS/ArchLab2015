void good() { while (1); }
void bad() { while (1); }

#define SWAP(x, y) do { \
    typeof(x) tmp = x;  \
    x = y;              \
    y = tmp;            \
} while (0)

#define ASSERT(x) do { \
    if (!(x)) bad();   \
} while (0)

int main()
{
    int a[2] = { 0 , 1 };
    SWAP(a[0], a[1]);
    ASSERT(a[0] == 1 && a[1] == 0);
    good();
    return 0;
}
