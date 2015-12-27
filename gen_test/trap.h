static void bad()
{
    while (1){
        bad();
    }

}
static void good()
{
    while (1){
        good();
    }
}

#define set_sp asm volatile("li $sp, 16000");

