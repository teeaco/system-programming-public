#include <stdio.h>
#include <stdbool.h>

bool is_non_decreasing(int n) {
    int current_digit, next_digit;
    current_digit = n % 10;
    n /= 10;
    while (n > 0) {
        next_digit = n % 10;
        if (next_digit > current_digit) {
            return false;
        }
        current_digit = next_digit;
        n /= 10;
    }
    return true;  
}

int main() {
    int number;
    scanf("%d", &number);
    if (is_non_decreasing(number)) {
        printf("yes\n");
    } else {
        printf("no\n");
    }

    return 0;
}
