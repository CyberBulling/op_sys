.file	"parent.c"          ; Исходный файл программы
	.text
	.section .rdata,"dr"   ; Секция read-only данных
.LC0:
	.ascii "Enter a number: \0"  ; Приглашение для ввода числа
.LC1:
	.ascii "%d\0"                ; Формат для ввода числа
.LC2:
	.ascii "child.exe %d\0"      ; Формат команды для запуска child.exe
.LC3:
	.ascii "[PARENT] %d! = %d\12\0"  ; Формат вывода результата (\12 = \n)
.LC4:
	.ascii "%.*s\0"              ; Формат для вывода строки фиксированной длины

	.text
	.globl	main                ; Объявляем main глобальной
	.def	main;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	main            ; Начало функции с поддержкой SEH

main:
	; Пролог функции
	pushq	%rbp                ; Сохраняем предыдущее значение RBP
	.seh_pushreg	%rbp
	pushq	%rdi                ; Сохраняем RDI
	.seh_pushreg	%rdi
	subq	$664, %rsp          ; Выделяем 664 байта в стеке
	.seh_stackalloc	664
	leaq	128(%rsp), %rbp      ; Устанавливаем новый базовый указатель
	.seh_setframe	%rbp, 128
	.seh_endprologue           ; Конец пролога SEH

	call	__main              ; Инициализация GCC

	; Вывод приглашения для ввода
	leaq	.LC0(%rip), %rax    ; Загружаем адрес строки приглашения
	movq	%rax, %rcx          ; Первый аргумент printf
	call	__mingw_printf      ; Выводим "Enter a number: "

	; Ввод числа от пользователя
	leaq	520(%rbp), %rax     ; Адрес переменной для хранения числа
	movq	%rax, %rdx          ; Второй аргумент scanf
	leaq	.LC1(%rip), %rax    ; Загружаем формат "%d"
	movq	%rax, %rcx          ; Первый аргумент scanf
	call	__mingw_scanf       ; Читаем число с клавиатуры

	; Настройка атрибутов канала (pipe)
	movl	$24, 480(%rbp)      ; Размер структуры SECURITY_ATTRIBUTES
	movq	$0, 488(%rbp)       ; NULL для дескриптора безопасности
	movl	$1, 496(%rbp)       ; TRUE для наследуемости дескриптора

	; Создание канала (pipe)
	leaq	480(%rbp), %rcx     ; Указатель на SECURITY_ATTRIBUTES
	leaq	504(%rbp), %rdx     ; Указатель на дескриптор чтения
	leaq	512(%rbp), %rax     ; Указатель на дескриптор записи
	movl	$0, %r9d            ; 0 для размера буфера
	movq	%rcx, %r8           ; SECURITY_ATTRIBUTES
	movq	%rax, %rcx          ; Указатель на дескриптор записи
	movq	__imp_CreatePipe(%rip), %rax  ; Загружаем адрес CreatePipe
	call	*%rax               ; Вызываем CreatePipe

	; Подготовка структуры STARTUPINFO
	leaq	368(%rbp), %rdx     ; Адрес структуры STARTUPINFO
	movl	$0, %eax            ; Обнуляем EAX
	movl	$13, %ecx           ; 13 qwords = 104 bytes (размер STARTUPINFO)
	movq	%rdx, %rdi          ; Назначение для STOSQ
	rep stosq                ; Заполняем нулями

	; Формирование командной строки для child.exe
	movl	520(%rbp), %edx     ; Загружаем введенное число
	leaq	80(%rbp), %rax      ; Буфер для командной строки
	movl	%edx, %r8d          ; Число как аргумент для sprintf
	leaq	.LC2(%rip), %rdx    ; Формат "child.exe %d"
	movq	%rax, %rcx          ; Буфер для результата
	call	__mingw_sprintf     ; Формируем строку "child.exe N"

	; Настройка STARTUPINFO для перенаправления вывода
	movl	$104, 368(%rbp)     ; cb (размер структуры)
	movq	504(%rbp), %rax     ; Дескриптор записи в канал
	movq	%rax, 456(%rbp)     ; hStdOutput для дочернего процесса
	movl	$256, 428(%rbp)     ; dwFlags

	; Создание дочернего процесса
	leaq	80(%rbp), %rax      ; Командная строка
	leaq	336(%rbp), %rdx     ; Указатель на PROCESS_INFORMATION
	movq	%rdx, 72(%rsp)      ; 7-й аргумент (PROCESS_INFORMATION)
	leaq	368(%rbp), %rdx     ; Указатель на STARTUPINFO
	movq	%rdx, 64(%rsp)      ; 6-й аргумент
	movq	$0, 56(%rsp)        ; 5-й аргумент (текущий каталог)
	movq	$0, 48(%rsp)        ; 4-й аргумент (дескрипторы среды)
	movl	$0, 40(%rsp)        ; 3-й аргумент (флаги создания)
	movl	$1, 32(%rsp)        ; 2-й аргумент (наследование дескрипторов)
	movl	$0, %r9d            ; 1-й аргумент (дескриптор безопасности)
	movl	$0, %r8d            ; 0 для lpThreadAttributes
	movq	%rax, %rdx          ; Командная строка
	movl	$0, %ecx            ; NULL для lpApplicationName
	movq	__imp_CreateProcessA(%rip), %rax  ; Адрес CreateProcessA
	call	*%rax               ; Вызываем CreateProcessA

	; Вычисление факториала в родительском процессе
	movl	520(%rbp), %eax     ; Загружаем введенное число
	movl	%eax, %ecx          ; Аргумент для factorial
	call	factorial           ; Вызываем factorial(n)
	movl	%eax, 524(%rbp)     ; Сохраняем результат

	; Вывод результата вычисления факториала
	movl	520(%rbp), %eax     ; Введенное число
	movl	524(%rbp), %edx      ; Результат factorial(n)
	movl	%edx, %r8d          ; Третий аргумент printf
	movl	%eax, %edx          ; Второй аргумент
	leaq	.LC3(%rip), %rax    ; Формат "[PARENT] %d! = %d\n"
	movq	%rax, %rcx          ; Первый аргумент
	call	__mingw_printf      ; Выводим результат

	; Закрываем ненужный дескриптор
	movq	504(%rbp), %rax     ; Дескриптор записи в канал
	movq	%rax, %rcx          ; Аргумент для CloseHandle
	movq	__imp_CloseHandle(%rip), %rax
	call	*%rax               ; Закрываем дескриптор
	jmp	.L2                  ; Переход к проверке условия
	
.L4:
	; Вывод прочитанных данных
	movl	-36(%rbp), %eax     ; Количество прочитанных байт
	movl	%eax, %edx          ; Третий аргумент printf (длина)
	leaq	-32(%rbp), %rax     ; Буфер с данными
	movq	%rax, %r8           ; Второй аргумент (строка)
	leaq	.LC4(%rip), %rax    ; Формат "%.*s"
	movq	%rax, %rcx          ; Первый аргумент
	call	__mingw_printf      ; Выводим строку

.L2:
	; Чтение из канала
	movq	512(%rbp), %rax     ; Дескриптор чтения из канала
	leaq	-36(%rbp), %rcx     ; Указатель на переменную для количества байт
	leaq	-32(%rbp), %rdx     ; Буфер для чтения
	movq	$0, 32(%rsp)        ; 5-й аргумент (OVERLAPPED)
	movq	%rcx, %r9           ; 4-й аргумент (число прочитанных байт)
	movl	$100, %r8d          ; 3-й аргумент (размер буфера)
	movq	%rax, %rcx          ; 1-й аргумент (дескриптор)
	movq	__imp_ReadFile(%rip), %rax
	call	*%rax               ; Читаем данные из канала

	testl	%eax, %eax          ; Проверяем результат ReadFile
	je	.L3                  ; Если ошибка, переходим к закрытию
	movl	-36(%rbp), %eax     ; Количество прочитанных байт
	testl	%eax, %eax          ; Проверяем, есть ли данные
	jne	.L4                  ; Если есть, выводим их

.L3:
	; Закрываем дескрипторы
	movq	512(%rbp), %rax     ; Дескриптор чтения из канала
	movq	%rax, %rcx
	movq	__imp_CloseHandle(%rip), %rax
	call	*%rax               ; Закрываем дескриптор

	movq	336(%rbp), %rax     ; Дескриптор процесса
	movq	%rax, %rcx
	call	*%rax               ; Закрываем дескриптор процесса

	movq	344(%rbp), %rax     ; Дескриптор потока
	movq	%rax, %rcx
	call	*%rax               ; Закрываем дескриптор потока

	movl	$0, %eax            ; Код возврата 0
	addq	$664, %rsp          ; Освобождаем стек
	popq	%rdi                ; Восстанавливаем RDI
	popq	%rbp                ; Восстанавливаем RBP
	ret                       ; Выход из программы

	; Внешние зависимости
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"
	.def	factorial;	.scl	2;	.type	32;	.endef