#include <stdio.h>

int main(void) {
    unsigned long long number = 4693338485;
    unsigned long long sum = 0;
    unsigned long long temp = number;

    while (temp > 0) {
        sum += temp % 10;
        temp /= 10;
    }

    printf("%llu\n", sum);

    return 0;
}