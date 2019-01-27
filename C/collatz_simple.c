#include <stdio.h>
#include <x86intrin.h>

typedef struct {
    int gate;
    int peak;
    int length;
} route;

route top4[4];

route collatz(int gate) {
    route ret;
    ret.gate = gate;
    ret.peak = gate;
    ret.length = 0;

    while (gate > 1) {
        if (gate & 1) {
            gate = (gate << 1) + gate + 1;
        } else {
            gate >>= 1;
        }

        if (gate > ret.peak) ret.peak = gate;
        ret.length++;
    }

    return ret;
}

void swap(int* a, int* b) {
    *a ^= *b;
    *b ^= *a;
    *a ^= *b;
}

void sort(route r) {
    route top5[5];
    for (int i = 0; i < 4; i++) top5[i] = top4[i];
    top5[4] = r;

    int same = 0;
    int i;
    for (i = 0; i < 4; i++) {
        if (top5[i].peak == top5[4].peak) {
            same = 1;
            if (top5[i].length < top5[4].length) {
                top5[i] = top5[4];
            }
            break;
        }
    }

    if (!same) {
        for (int i = 3; i >= 0; i--) {
            if (top5[i].peak < top5[i + 1].peak) {
                swap(&top5[i].gate, &top5[i + 1].gate);
                swap(&top5[i].peak, &top5[i + 1].peak);
                swap(&top5[i].length, &top5[i + 1].length);
            }
        }
    }

    for (int i = 0; i < 4; i++) {
        top4[i] = top5[i];
    }
}

int main(void) {
    unsigned long long ts0 = _rdtsc();
    int i;
    for (i = 1; i < 1024; i++) {
        route res = collatz(i);
        sort(res);
    }

    for (int i = 0; i < 4; i++) {
        printf("%d %d %d\n", top4[i].gate, top4[i].peak, top4[i].length);
    }

    printf("clock: %llu\n", _rdtsc() - ts0);
}
