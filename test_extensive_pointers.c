int main() {
    int a, b, c;
    int *p1, *p2;
    
    // Basic assignment
    a = 1;
    b = 2;
    p1 = &a;
    p2 = &b;

    // Arithmetic with dereferences
    c = *p1 + *p2 * 3; // expected: 1 + 2 * 3 = 7
    printf(c);

    // Conditional with dereference
    if (*p1 < *p2) {
        *p1 = *p2; // a becomes 2
    }
    printf(a); // expected 2

    // Loop modifying via pointer
    while (*p1 < 10) {
        *p1 = *p1 + 1; 
    }
    printf(a); // expected 10

    // Pointer reassignment
    p1 = &c;
    *p1 = a / 2; // c = 10 / 2 = 5
    printf(c); // expected 5
}
