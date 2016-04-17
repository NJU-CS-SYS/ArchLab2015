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
    int a = 0;
    int b = 11;
    int c = 90;
    if(a == c%b) {
        return goodtrap();
    }
    else {
        return badtrap();
    }
}
