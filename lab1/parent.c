#include <stdio.h>
#include <windows.h>
#include "math_functions.h"

int main() {
    // Создаем pipe
    HANDLE hReadPipe, hWritePipe;
    SECURITY_ATTRIBUTES sa = { sizeof(SECURITY_ATTRIBUTES), NULL, TRUE };
    CreatePipe(&hReadPipe, &hWritePipe, &sa, 0);

    // Настраиваем дочерний процесс
    STARTUPINFO si = { sizeof(STARTUPINFO) };
    PROCESS_INFORMATION pi;
    char cmdline[] = "child.exe";

    // Перенаправляем stdout дочернего процесса в наш pipe
    si.hStdOutput = hWritePipe;
    si.dwFlags = STARTF_USESTDHANDLES;

    // Запускаем дочерний процесс
    CreateProcess(NULL, cmdline, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

    // Родитель вычисляет факториал 6
    int parent_result = factorial(6);
    printf("[PARENT] 6! = %d\n", parent_result);

    // Закрываем ненужный дескриптор записи
    CloseHandle(hWritePipe);

    // Читаем вывод дочернего процесса
    char buffer[100];
    DWORD bytesRead;
    while (ReadFile(hReadPipe, buffer, sizeof(buffer), &bytesRead, NULL) && bytesRead != 0) {
        printf("%.*s", (int)bytesRead, buffer);
    }

    // Закрываем дескрипторы
    CloseHandle(hReadPipe);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    
    return 0;
}