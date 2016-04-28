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
    int a = 1;
    int b = 2;
    int c = 2;
    if(c == a*b) {
        return goodtrap();
    }
    else {
        return badtrap();
    }
}
