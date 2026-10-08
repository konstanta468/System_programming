#include <stdio.h>

int main(void) {
    int n;

    if (scanf("%d", &n) != 1 || n < 1) {
        return 1;
    }

    long long sum = 0;

    for (long long k = 1; k <= n; k++) {
        long long sign = (k % 2 == 0) ? 1 : -1;

        long long term = sign * k * (k + 1) * (3 * k + 1) * (3 * k + 2);

        sum += term;
    }

    printf("%lld\n", sum);

    return 0;
}