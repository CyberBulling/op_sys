.file	"math_functions.c"  ; Исходный файл программы
	.text                   ; Начало секции кода
	.globl	factorial       ; Объявляем factorial глобальной видимости
	.def	factorial;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	factorial   ; Начало функции с поддержкой SEH

factorial:
	; Пролог функции
	pushq	%rbp            ; Сохраняем предыдущее значение RBP
	.seh_pushreg	%rbp    ; Информация для SEH
	movq	%rsp, %rbp      ; Устанавливаем новый фрейм стека
	.seh_setframe	%rbp, 0 
	subq	$32, %rsp       ; Выделяем 32 байта в стеке
	.seh_stackalloc	32      
	.seh_endprologue        ; Конец пролога SEH

	; Сохранение параметра функции
	movl	%ecx, 16(%rbp)  ; Сохраняем входной аргумент (n) в стек [RBP+16]

	; Проверка базового случая рекурсии (n <= 1)
	cmpl	$1, 16(%rbp)    ; Сравниваем n с 1
	jg	.L2              ; Если n > 1, переходим к рекурсивному случаю
	movl	$1, %eax     ; Базовый случай: возвращаем 1
	jmp	.L3              ; Переходим к эпилогу функции

.L2:                        ; Рекурсивный случай
	; Подготовка аргумента для рекурсивного вызова (n-1)
	movl	16(%rbp), %eax  ; Загружаем n в EAX
	subl	$1, %eax        ; Вычисляем n-1
	movl	%eax, %ecx      ; Помещаем n-1 в ECX
	call	factorial       ; Рекурсивный вызов factorial(n-1)

	; Умножение результата на текущее n
	imull	16(%rbp), %eax  ; EAX = factorial(n-1) * n

.L3:                        ; Общая точка возврата
	; Эпилог функции
	addq	$32, %rsp       ; Освобождаем стек
	popq	%rbp            ; Восстанавливаем предыдущий RBP
	ret                     ; Возврат из функции

	.seh_endproc            ; Конец функции
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"  ; Версия компилятора