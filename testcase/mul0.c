volatile inline int goodtrap()
{
    while(1);
    return 0;
}
volatile inline int badtrap()
{
    while(1);
    return 0;
}
int main()
{
    int a = 9;
    int b = 10;
    int c = 90;
    if(c != a*b) {
        return badtrap();
    }

    a = 81;
    b = 1;
    c = 81;
    if(c != a*b) {
        return badtrap();
    }
    a = 7;
    b = 8;
    c = 56;
    if(c != a*b) {
        return badtrap();
    }
    return 0;
}
