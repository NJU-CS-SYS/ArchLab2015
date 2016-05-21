void put_hex(unsigned int x, char *addr) {
    int i;
    *addr++ = '0';
    *addr++ = 'x';
    for (i = 0; i < 8; i++) {
        unsigned int val = (x >> ((7 - i) << 2)) & 0xf;
        if (val >= 16) {
            *addr++ = '?';
        }
        else if (val < 10) {
            *addr++ = ((char) val) + '0';
        }
        else {
            *addr++ = ((char) val) - 10 + 'a';
        }
    }
}
