#define VMEM ((char *)0xc0000000)

char *a = "Hello, World!";

int main() {
    char *vga = VMEM;
    while (*a) {
        *vga++ = *a++;
    }
    return 0;
}
