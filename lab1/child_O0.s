.file	"child.c"           ; Исходный файл программы
	.text
	.section .rdata,"dr"   ; Секция read-only данных
.LC0:
	.ascii "Usage: child.exe <number>\0"  ; Строка сообщения об ошибке
.LC1:
	.ascii "[CHILD] %d! = %d\12\0"       ; Строка формата вывода результата
	.text
	.globl	main            ; Объявление main как глобального
	.def	main;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	main       ; Начало функции с поддержкой SEH

main:
	; Пролог функции
	pushq	%rbp            ; Сохраняем предыдущее значение RBP
	.seh_pushreg	%rbp    
	movq	%rsp, %rbp      ; Устанавливаем новый фрейм стека
	.seh_setframe	%rbp, 0 
	subq	$48, %rsp       ; Выделяем 48 байт в стеке
	.seh_stackalloc	48      
	.seh_endprologue        ; Конец SEH-информации

	; Сохранение аргументов
	movl	%ecx, 16(%rbp)  ; argc сохраняем в стек
	movq	%rdx, 24(%rbp)  ; argv сохраняем в стек
	call	__main          ; Инициализация GCC

	; Проверка количества аргументов
	cmpl	$1, 16(%rbp)    ; Сравниваем argc с 1
	jg	.L2              ; Если > 1 (есть аргументы), переходим к .L2

	; Обработка ошибки (нет аргументов)
	leaq	.LC0(%rip), %rax  ; Загружаем адрес строки ошибки
	movq	%rax, %rcx      ; Подготавливаем аргумент для puts
	call	puts            ; Выводим сообщение об ошибке
	movl	$1, %eax        ; Возвращаем код ошибки 1
	jmp	.L3              ; Переходим к завершению программы

.L2:
	; Получение и обработка аргумента
	movq	24(%rbp), %rax  ; Загружаем argv
	addq	$8, %rax        ; Переходим к argv[1]
	movq	(%rax), %rax    ; Получаем строку-аргумент
	movq	%rax, %rcx      ; Подготавливаем аргумент для atoi
	call	atoi            ; Преобразуем строку в число
	subl	$1, %eax        ; Вычисляем n-1 (по условию задачи?)
	movl	%eax, -4(%rbp)  ; Сохраняем в локальную переменную [RBP-4]

	; Вычисление факториала
	movl	-4(%rbp), %eax  
	movl	%eax, %ecx      ; Подготавливаем аргумент для factorial
	call	factorial       ; Вызываем функцию factorial(n-1)
	movl	%eax, -8(%rbp)  ; Сохраняем результат в [RBP-8]

	; Вывод результата
	movl	-8(%rbp), %edx  ; Результат factorial(n-1)
	movl	-4(%rbp), %eax  ; Значение n-1
	movl	%edx, %r8d      ; Третий аргумент printf (результат)
	movl	%eax, %edx      ; Второй аргумент printf (n-1)
	leaq	.LC1(%rip), %rax  ; Загружаем строку формата
	movq	%rax, %rcx      ; Первый аргумент printf
	call	__mingw_printf  ; Выводим результат

	movl	$0, %eax        ; Успешный код возврата 0

.L3:
	; Эпилог функции
	addq	$48, %rsp       ; Освобождаем стек
	popq	%rbp            ; Восстанавливаем RBP
	ret                     ; Возврат из функции
	.seh_endproc            ; Конец функции

	; Внешние зависимости
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
	.def	atoi;	.scl	2;	.type	32;	.endef
	.def	factorial;	.scl	2;	.type	32;	.endef