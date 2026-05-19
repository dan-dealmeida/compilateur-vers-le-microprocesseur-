main() {
    const c = 2;
    int i, j, k, r, big;

    i = 3;
    j = 4;
    k = 8;
    r = (i + j) * (i + k / j);
    big = 1e3 + c;

    printf(r);
    printf(i);
    printf(big);
}
