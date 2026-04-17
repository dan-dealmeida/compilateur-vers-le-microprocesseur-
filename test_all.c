// Test file to validate the entire C compiler feature set

// Custom function using recursion mathematically
int factorial(int n) {
    int res;
    if (n < 2) {
        res = 1;
    } else {
        res = n * factorial(n - 1);
    }
    return res;
}

// Custom function utilizing pointers
int swap_and_add(int *pA, int *pB) {
    int temp, sum;
    
    // Read pointers
    sum = *pA + *pB;
    
    // Swap pointers
    temp = *pA;
    *pA = *pB;
    *pB = temp;
    
    return sum;
}

int main() {
    int x, y, fact_res, swap_res;
    int *px, *py;
    int i, loop_sum;

    // 1. Basic Arithmetic and Assignment
    x = 5;
    y = 10;
    
    // 2. Control Flow: IF / ELSE and Print
    if (x == y) {
        printf(y); // Should not reach
    } else {
        printf(x); // Should print 5
    }

    // 3. While Loop and Precedence Arithmetic
    i = 0;
    loop_sum = 0;
    while (i < 3) {
        loop_sum = loop_sum + (i * 2); 
        i = i + 1;
    }
    printf(loop_sum); // Expected: 0 + (0) + (1*2) + (2*2) = 6

    // 4. Function Call with Recursion
    // Calling factorial(4) = 24
    fact_res = factorial(4);
    printf(fact_res);

    // 5. Pointers & Pointers passed into functions
    px = &x;
    py = &y;
    // Currently x=5, y=10. Calling swap_and_add should return 15
    swap_res = swap_and_add(px, py);
    
    printf(swap_res); // Expected 15
    printf(x);        // Expected 10 (since x and y swapped via dereference)
    printf(y);        // Expected 5
}
