#define VMEM 0xc0000000

int main() {
    unsigned char *vgamem = (unsigned char *) VMEM;
    *(vgamem++) = '0';
    *(vgamem++) = '1';
    *(vgamem++) = '2';
    *(vgamem++) = '3';
    *(vgamem++) = '4';
    *(vgamem++) = '5';
    *(vgamem++) = '6';
    *(vgamem++) = '7';
    *(vgamem++) = '8';
    *(vgamem++) = '9';
    return 0;
}
