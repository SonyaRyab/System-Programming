#include <stdio.h>
#include <math.h>

int main() {
    //int k;
    int n;
    int result = 0;
    printf("n = ");
    scanf("%d", &n);
    //printf("k = ");
    //scanf("%d", &k);

    for (int k = 1; k <= n; k++) {
        result += pow(-1, k)*k*(k+4)*(k+8);
    }
    printf("Сумма равна: ");
    printf("%d\n", result);
    return 0;
}