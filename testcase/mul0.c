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
    if(c == a*b) {
        return goodtrap();
    }
    else {
        return badtrap();
    }
}
