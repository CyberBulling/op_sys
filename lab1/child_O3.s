.file	"child.c"           ; Исходный файл программы
	.text
	.section .rdata,"dr"   ; Секция read-only данных
.LC0:
	.ascii "Usage: child.exe <number>\0"  ; Сообщение об ошибке (неправильный вызов)
.LC1:
	.ascii "[CHILD] %d! = %d\12\0"       ; Строка формата вывода результата (\12 = \n)
	
	.section	.text.startup,"x"  ; Секция кода запуска программы
	.p2align 4               ; Выравнивание кода по 16-байтной границе
	.globl	main             ; Объявляем main глобальной видимости
	.def	main;	.scl	2;	.type	32;	.endef  ; Метаданные для отладчика
	.seh_proc	main        ; Начало функции с поддержкой SEH

main:
	; Пролог функции
	pushq	%rsi             ; Сохраняем регистр RSI
	.seh_pushreg	%rsi     ; Информация для SEH
	pushq	%rbx             ; Сохраняем регистр RBX
	.seh_pushreg	%rbx     
	subq	$40, %rsp        ; Выделяем 40 байт в стеке
	.seh_stackalloc	40       
	.seh_endprologue         ; Конец пролога SEH

	; Сохранение аргументов в регистры вместо стека
	movl	%ecx, %ebx       ; Сохраняем argc в EBX
	movq	%rdx, %rsi       ; Сохраняем argv в RSI
	call	__main           ; Инициализация GCC

	; Проверка количества аргументов
	cmpl	$1, %ebx         ; Сравниваем argc с 1
	jle	.L5               ; Если <= 1 (нет аргументов), переходим к ошибке

	; Получение и обработка аргумента
	movq	8(%rsi), %rcx    ; Загружаем argv[1] (адрес строки)
	call	atoi             ; Преобразуем строку в число
	leal	-1(%rax), %ebx   ; Вычисляем n-1 и сохраняем в EBX

	; Вычисление факториала
	movl	%ebx, %ecx       ; Передаем n-1 в ECX
	call	factorial        ; Вызываем factorial(n-1)

	; Вывод результата
	movl	%ebx, %edx       ; Второй параметр printf: n-1
	leaq	.LC1(%rip), %rcx ; Первый параметр: строка формата
	movl	%eax, %r8d       ; Третий параметр: результат factorial
	call	__mingw_printf   ; Выводим "[CHILD] (n-1)! = результат"

	xorl	%eax, %eax       ; Успешный код возврата 0

.L1:
	; Эпилог функции
	addq	$40, %rsp        ; Освобождаем стек
	popq	%rbx             ; Восстанавливаем RBX
	popq	%rsi             ; Восстанавливаем RSI
	ret                     ; Возврат из функции

.L5:
	; Обработка ошибки (нет аргументов)
	leaq	.LC0(%rip), %rcx ; Загружаем сообщение об ошибке
	call	puts             ; Выводим "Usage: child.exe <number>"
	movl	$1, %eax         ; Код возврата 1
	jmp	.L1               ; Переход к эпилогу

	; Внешние зависимости
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"
	.def	atoi;	.scl	2;	.type	32;	.endef
	.def	factorial;	.scl	2;	.type	32;	.endef
	.def	puts;	.scl	2;	.type	32;	.endef