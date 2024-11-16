#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int a = atoi(argv[1]);  /*str->int */
    int c = atoi(argv[2]);
    int result = ((a-a)+a)-c;
    printf("((%d - % d) + %d) - %d = %d\n", a, a, a, c, result);
    return 0;
}
