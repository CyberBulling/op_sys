#include <stdio.h>
#include <windows.h>
#include "math_functions.h"

int main() {
    // Вычисляем факториал
    int result = factorial(5);
    
    // Выводим результат (будет перехвачен родительским процессом)
    printf("[CHILD] 5! = %d\n", result);
    
    return 0;
}