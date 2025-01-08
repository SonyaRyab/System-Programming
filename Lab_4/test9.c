//Для n вычислить сумму 1+2-3-4+5+6-7-8+...+-n 

#include <stdio.h>
#include <math.h>

int main() {
    int n, sum = 0, sign=1;
    printf("n = ");
    scanf("%d", &n);
    for (int i = 1; i <= n; i++) {
        if (i%4==1) {
            sum += i*sign;
        } else if (i%4==2) {
            sum += i*sign;
        }
        else if (i%4==3) {
            sum -= i*sign;
        }
        else {
            sum -= i*sign;
        }

    }
    printf("Сумма равна %d\n", sum);
    return 0;
}