#include<stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * free_memory();
unsigned int ranint();
void randi_array(unsigned long*, unsigned long);

int main(){
  unsigned long *p, n, *mass;
  p = 0;
  scanf("%ld",&n);
  p = create_array(3);
  p[0] = 8;
  randi_array(p, n);
  
  printf("%ld\n%ld\n%ld\n%ld\n",p[0],p[1],p[2],p[3]);
  free_memory(p);
  
  return 0;
}