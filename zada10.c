#include <stdio.h>
#include <string.h>

#define MAX_ATTEMPTS 5

int main() {
    char correct_password[50];
    char input[50];
    int attempts = 0;

    // Ввод правильного пароля изначально
    printf("Введите пароль для настройки: ");
    scanf("%s", correct_password);

    // Цикл для проверки попыток ввода
    while (attempts < MAX_ATTEMPTS) {
        printf("Введите пароль для входа: ");
        scanf("%s", input);

        if (strcmp(input, correct_password) == 0) {
            printf("Вошли\n");
            return 0;
        } else {
            printf("Неверный пароль\n");
            attempts++;
        }
    }

    printf("Неудача\n");
    return 1;
}
