int main() {
    // 1. Missing semicolon in declarations
    int valid_var;
    int missing_semi
    int another_valid;

    // 2. Assignment without an expression
    valid_var = ;

    // 3. Typo in keywords 
    if (valid_var == 5) {
        printf(valid_var);
    } else {
        printf(another_valid);
    
    // 4. Missing closing parenthesis in arithmetic
    another_valid = (valid_var + 10 * 3;

    // 5. Unrecognized characters
    valid_var = another_valid + @;

    // 6. Using an undeclared Semantic variable
    fake_variable = 100;
}
