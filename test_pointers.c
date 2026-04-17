int main() {
    int a, b;
    int *p;
    a = 5;
    p = &a;
    b = *p;
    *p = 10;
    
    printf(a);
    printf(b);
}
