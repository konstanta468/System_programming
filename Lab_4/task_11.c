#include <stdio.h>

int main(void) {
    int count = 0;
    int vote = 0;
    int yes_votes = 0;
    int no_votes = 0;

    if (scanf("%d", &count) != 1 || count <= 0) {
        return 1;
    }

    for (int i = 0; i < count; i++) {
        if (scanf("%d", &vote) != 1) {
            return 1;
        }
        if (vote == 1) {
            yes_votes++;
        } else {
            no_votes++;
        }
    }

    if (yes_votes > no_votes) {
        printf("1\n");
    } else if (no_votes > yes_votes) {
        printf("0\n");
    } else {
        printf("-1\n");
    }

    return 0;
}