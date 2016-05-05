#define VMEM 0xc0000000

int main() {
    unsigned char *vgamem = (unsigned char *) (VMEM+320);
    *(vgamem++) = 'H';
    *(vgamem++) = 'e';
    *(vgamem++) = 'l';
    *(vgamem++) = 'l';
    *(vgamem++) = 'o';
    *(vgamem++) = 'W';
    *(vgamem++) = 'o';
    *(vgamem++) = 'r';
    *(vgamem++) = 'l';
    *(vgamem++) = 'd';
    if(*vgamem == 'a') {
        while(1);
    }
    else {
        while(1);
    }
    return 0;
}
