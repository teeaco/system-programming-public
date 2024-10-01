#include <stdio.h>
int main()
{
  int s;
  printf("Введите символ: ");
  s = getchar();
  printf("это символ (%c ), а это его ASCII - код: (%d )\n", s,s);
  return 0;
}