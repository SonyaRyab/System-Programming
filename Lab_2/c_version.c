#include <stdio.h>

int main() {
    int sum = 0;
    long long int number = 5607798014;
    while (number > 0) {
        sum += number % 10; 
        number /= 10; 
    } 
    printf("%d\n", sum);
    return 0;
}