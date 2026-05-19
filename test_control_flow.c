int main() {
    int i, sum;

    i = 0;
    sum = 0;

    while (i < 4) {
        sum = sum + i;
        i = i + 1;
    }

    if (sum == 6) {
        printf(sum);
    } else {
        printf(i);
    }
}
