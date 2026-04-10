int main() {
    int a, b, c;
    int sum, max;

    // 1. Arithmetic and precedence
    a = 10;
    b = 20;
    c = 5;
    
    // sum = 10 + (20 * 5) - (10 / 2) = 10 + 100 - 5 = 105
    sum = a + b * c - (a / 2);
    printf(sum);

    // 2. Simple IF (a < b is true)
    if (a < b) {
        printf(a); 
    }

    // 3. IF / ELSE (a == 100 is false)
    if (a == 100) {
        printf(a); 
    } else {
        printf(b); 
    }

    // 4. Nested IF / ELSE
    if (b > a) {
        if (c < 10) {
            max = b;
            printf(max); 
        } else {
            max = a;
        }
    }

    // 5. While loop (counts down from 5 to 1)
    while (c > 0) {
        printf(c); 
        c = c - 1;
    }
}
