#include <stdio.h>

extern void push_back(long long int x);   /*добавление элемента в конец*/
extern long long int pop_front();   /*удаление элемента из начала*/
extern long long int count_1();  /*кол-во элементов, оканчивающихся на 1*/
extern long long int count_even();   /*кол-во четных элементов*/
extern void remove_even();     /*удаление четных элементов*/
extern void fill_rand(long long int c);    /*заполнение случайными числами*/
extern void printstr(char* c); 
extern void printhex(unsigned long long int x); 
extern long long int get_size();

int main() {
  //printhex(2024);
  long long t;
  printf("\n10 random numbers: ");
  fill_rand(10);  /*заполнение 10 случайными числами в конец очереди*/
  
  //printf("\npop front: ");  
  for(int i = 0; i < 10; ++i) {
  	t = pop_front();  /*извлечение элемента из начала очереди*/
    printf("%lld ", t);  
  	push_back(t);   /*добавление элемента в конец*/
  }
  t = count_even();
  printf("\n");
  printf("\neven: %lld\n", t);  
  t = count_1();
  printf("\n1-ended: %lld\n", t);
  remove_even();
  printf("\nafter remove even: ");
  while(get_size()>0) {
  	t = pop_front();
  	printf(" %lld ", t);
  	//push_back(t);
  }
  printf("\n");
  return 0;
}