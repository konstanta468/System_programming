#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

bool is_non_decreasing(long long n) {
    n = llabs(n);
    int last_digit = 10;

    while (n > 0) {
        int current_digit = n % 10;
        if (current_digit > last_digit) {
            return false;
        }
        last_digit = current_digit;
        n /= 10;
    }

    return true;
}

int main(void) {
    long long number;

    if (scanf("%lld", &number) != 1) {
        return 1;
    }

    if (is_non_decreasing(number)) {
        printf("1\n");
    } else {
        printf("0\n");
    }

    return 0;
}