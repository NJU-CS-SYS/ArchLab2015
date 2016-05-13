#define VMEM ((char *)0xc0000000)

char *str = "Hello, World!";
char *vga = VMEM;

int main() {
    while (*str) {
        *vga++ = *str++;
    }
    return 0;
}
