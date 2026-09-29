#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    unsigned int a, b, c;
    unsigned int result;

    if (argc != 4) {
        return 1; // Выходим с ошибкой
    }

    a = atof(argv[1]);
    b = atof(argv[2]);
    c = atof(argv[3]);

    if (b == 0) {
        return 1;
    }

    result = (((((c + b) - b) + a) / b) - a);

    printf("%u\n", result);

    return 0;
}