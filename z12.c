#include <stdio.h>
#include <stdbool.h>

bool is_non_decreasing(int n) {
    int current_digit, next_digit;

    // Берем последнюю цифру числа
    current_digit = n % 10;
    n /= 10;

    // Проверяем каждую пару цифр, начиная с конца
    while (n > 0) {
        next_digit = n % 10;
        
        // Если следующая цифра больше текущей, то порядок нарушен
        if (next_digit > current_digit) {
            return false;
        }

        // Продвигаемся дальше по числу
        current_digit = next_digit;
        n /= 10;
    }

    return true;  // Если не было нарушений, возвращаем true
}

int main() {
    int number;

    // Ввод числа
    printf("Введите число: ");
    scanf("%d", &number);

    // Проверяем, следуют ли цифры в неубывающем порядке
    if (is_non_decreasing(number)) {
        printf("Цифры числа следуют в неубывающем порядке\n");
    } else {
        printf("Цифры числа не следуют в неубывающем порядке\n");
    }

    return 0;
}
