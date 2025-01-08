#include <stdio.h>

int main() {
    int n;
    printf("Введите значение n: ");
    scanf("%d", &n);

    int lcm = 37 * 13; 
    int count = n / lcm;
    printf("Количество чисел: ");
    printf("%d", count);
    printf("\n");
    return 0;
}