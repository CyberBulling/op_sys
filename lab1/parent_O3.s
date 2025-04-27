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
	.ascii "[PARENT] %d! = %d\12\0"  ; Формат вывода результата
.LC4:
	.ascii "%.*s\0"              ; Формат для вывода строки фиксированной длины

	.section	.text.startup,"x"  ; Секция кода запуска
	.p2align 4               ; Выравнивание кода по 16-байтной границе
	.globl	main             ; Объявляем main глобальной
	.def	main;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	main        ; Начало функции с поддержкой SEH

main:
	; Пролог функции (оптимизированная версия)
	pushq	%r12             ; Сохраняем регистры
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$656, %rsp       ; Выделяем 656 байт в стеке
	.seh_stackalloc	656
	.seh_endprologue         ; Конец пролога SEH

	leaq	.LC4(%rip), %rbp ; Сохраняем адрес строки формата в RBP
	call	__main          ; Инициализация GCC

	; Вывод приглашения для ввода
	leaq	.LC0(%rip), %rcx ; Формат строки приглашения
	leaq	400(%rsp), %rbx  ; Буфер для командной строки
	call	__mingw_printf  ; Выводим "Enter a number: "

	; Ввод числа от пользователя
	leaq	88(%rsp), %rdx   ; Адрес переменной для числа
	leaq	.LC1(%rip), %rcx ; Формат "%d"
	call	__mingw_scanf    ; Читаем число с клавиатуры

	; Настройка и создание канала (pipe)
	leaq	288(%rsp), %rdi  ; Адрес структуры STARTUPINFO
	xorl	%r9d, %r9d       ; Обнуляем R9D
	leaq	104(%rsp), %rdx  ; Указатель на дескриптор чтения
	leaq	96(%rsp), %rcx   ; Указатель на дескриптор записи
	leaq	112(%rsp), %r8   ; Указатель на SECURITY_ATTRIBUTES
	movl	$24, 112(%rsp)   ; Размер структуры SECURITY_ATTRIBUTES
	movq	$0, 120(%rsp)    ; NULL для дескриптора безопасности
	movl	$1, 128(%rsp)    ; TRUE для наследуемости дескриптора
	call	*__imp_CreatePipe(%rip)  ; Создаем канал

	; Подготовка структуры STARTUPINFO
	movl	88(%rsp), %r8d   ; Загружаем введенное число
	xorl	%eax, %eax       ; Обнуляем EAX
	movl	$13, %ecx        ; 13 qwords = 104 bytes
	rep stosq             ; Заполняем структуру нулями

	; Формирование командной строки для child.exe
	leaq	.LC2(%rip), %rdx ; Формат "child.exe %d"
	movq	%rbx, %rcx       ; Буфер для результата
	leaq	92(%rsp), %rdi   ; Буфер для чтения данных
	call	__mingw_sprintf  ; Формируем строку "child.exe N"

	; Настройка STARTUPINFO для перенаправления вывода
	movq	104(%rsp), %rax  ; Дескриптор записи в канал
	xorl	%r9d, %r9d       ; Обнуляем R9D
	movq	%rbx, %rdx       ; Командная строка
	xorl	%r8d, %r8d       ; Обнуляем R8D
	xorl	%ecx, %ecx       ; NULL для lpApplicationName
	movl	$104, 288(%rsp)  ; cb (размер структуры)
	leaq	176(%rsp), %rbx  ; Буфер для чтения данных
	movq	%rax, 376(%rsp)  ; hStdOutput для дочернего процесса
	leaq	144(%rsp), %rax  ; Указатель на PROCESS_INFORMATION
	movq	%rax, 72(%rsp)   ; 7-й аргумент
	leaq	288(%rsp), %rax  ; Указатель на STARTUPINFO
	movl	$256, 348(%rsp)  ; dwFlags (STARTF_USESTDHANDLES)
	movq	%rax, 64(%rsp)   ; 6-й аргумент
	movq	$0, 56(%rsp)     ; 5-й аргумент (текущий каталог)
	movq	$0, 48(%rsp)     ; 4-й аргумент (дескрипторы среды)
	movl	$0, 40(%rsp)     ; 3-й аргумент (флаги создания)
	movl	$1, 32(%rsp)     ; 2-й аргумент (наследование дескрипторов)
	call	*__imp_CreateProcessA(%rip)  ; Запускаем дочерний процесс

	; Вычисление факториала в родительском процессе
	movl	88(%rsp), %ecx   ; Загружаем введенное число
	call	factorial        ; Вызываем factorial(n)
	movl	88(%rsp), %edx   ; Введенное число
	leaq	.LC3(%rip), %rcx ; Формат вывода
	movl	%eax, %r8d       ; Результат factorial(n)
	call	__mingw_printf   ; Выводим результат

	; Закрываем ненужный дескриптор
	movq	104(%rsp), %rcx  ; Дескриптор записи в канал
	movq	__imp_CloseHandle(%rip), %r12  ; Сохраняем адрес CloseHandle
	call	*%r12            ; Закрываем дескриптор

	; Чтение вывода из дочернего процесса
	movq	__imp_ReadFile(%rip), %rsi  ; Сохраняем адрес ReadFile
	jmp	.L2               ; Переход к проверке условия

	.p2align 4,,10          ; Оптимальное выравнивание для цикла
	.p2align 3
.L8:
	; Вывод прочитанных данных
	movl	92(%rsp), %edx   ; Количество прочитанных байт
	testl	%edx, %edx       ; Проверяем, есть ли данные
	je	.L5               ; Если нет, выходим
	movq	%rbx, %r8        ; Буфер с данными
	movq	%rbp, %rcx       ; Формат "%.*s"
	call	__mingw_printf   ; Выводим строку

.L2:
	; Чтение из канала
	movq	$0, 32(%rsp)     ; 5-й аргумент (OVERLAPPED)
	movq	96(%rsp), %rcx   ; Дескриптор чтения из канала
	movq	%rdi, %r9        ; Указатель на переменную для количества байт
	movq	%rbx, %rdx       ; Буфер для чтения
	movl	$100, %r8d       ; Размер буфера
	call	*%rsi            ; Читаем данные из канала
	testl	%eax, %eax       ; Проверяем результат
	jne	.L8               ; Если успешно, продолжаем чтение

.L5:
	; Закрываем оставшиеся дескрипторы
	movq	96(%rsp), %rcx   ; Дескриптор чтения из канала
	call	*%r12            ; CloseHandle
	movq	144(%rsp), %rcx  ; Дескриптор процесса
	call	*%r12            ; CloseHandle
	movq	152(%rsp), %rcx  ; Дескриптор потока
	call	*%r12            ; CloseHandle

	xorl	%eax, %eax       ; Код возврата 0
	addq	$656, %rsp       ; Освобождаем стек
	
	; Восстанавливаем регистры
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret                     ; Выход из программы

	; Внешние зависимости
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"
	.def	factorial;	.scl	2;	.type	32;	.endef