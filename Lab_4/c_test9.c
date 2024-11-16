#include <stdio.h>

int main() {
    int n;
    int sum = 0;
    printf("n = ");
    scanf("%d", &n);
    for (int i = 1; i <= n; i++) {
        if ((i / 2) % 2 == 0) {
            sum = sum+i;
        } else {
            sum = sum-i;
        }
    }
    printf("Сумма равна %d\n", sum);
    return 0;
}