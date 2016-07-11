int main()
{
    asm volatile ("mtc0 %0,$12"::"r"(0xffff));
    for (;;) {}
}
