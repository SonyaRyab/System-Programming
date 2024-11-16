#include <stdio.h>

int main() {
    int n;
    printf("Введите значение n: ");
    scanf("%d", &n);

    int lcm = 37 * 13; 
    int count = n / lcm;

    printf("%d/n", count);

    return 0;
}