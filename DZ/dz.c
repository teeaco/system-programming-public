#include<stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * free_memory();
unsigned int ranint();
void randi_array(unsigned long*, unsigned long);
unsigned int sum_array(unsigned long*, unsigned long);
unsigned int reverse_array(unsigned long*, unsigned long);
unsigned int chet_count(unsigned long*, unsigned long);

void print_array(unsigned long *arr, unsigned long size) {
    for (unsigned long i = 0; i < size; i++) {
        printf("%ld ", arr[i]);
    }
    printf("\n");  
}

int main(){
  unsigned long *p, n, *mass;
  int s;
  p = 0;
  scanf("%ld",&n);
  p = create_array(3);
  print_array(p, n);

  randi_array(p, n);
  print_array(p, n);

  s = sum_array(p, n);
  //printf("%ld\n%ld\n%ld\n%ld\n",p[0],p[1],p[2],p[3]);
  printf("sum = ");
  printf("%ld\n", s);

  reverse_array(p, n);
  print_array(p, n);
  //printf("%ld\n%ld\n%ld\n%ld\n",p[0],p[1],p[2],p[3]);
  int chet = chet_count(p, n);
  printf("kolvo chet: ");
  printf("%ld\n", chet);
  free_memory(p);
  
  return 0;
}