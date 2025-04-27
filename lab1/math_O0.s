.file	"math_functions.c"  ; Исходный файл
	.text                   ; Начало секции кода
	.globl	factorial       ; Объявление символа factorial как глобального
	.def	factorial;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	factorial   ; Начало функции с поддержкой SEH

factorial:                  ; Метка начала функции factorial
	pushq	%rbp            ; Сохраняем предыдущее значение RBP
	.seh_pushreg	%rbp    
	movq	%rsp, %rbp      ; Устанавливаем новый фрейм стека (RBP = RSP)
	.seh_setframe	%rbp, 0 
	subq	$32, %rsp       ; Выделяем 32 байта в стеке
	.seh_stackalloc	32      
	.seh_endprologue        ; Конец SEH-информации функции

	movl	%ecx, 16(%rbp)  ; Сохраняем аргумент в стеке по адресу [RBP+16]
	cmpl	$1, 16(%rbp)    ; Сравниваем n с 1
	jg	.L2              	; Если n > 1, переходим на метку .L2
	movl	$1, %eax        ; Иначе возвращаем 1 в EAX
	jmp	.L3              	; Переход к завершению функции

.L2:                        ; Рекурсия:
	movl	16(%rbp), %eax  ; Загружаем n в EAX
	subl	$1, %eax        ; Уменьшаем EAX на 1 (вычисляем n-1)
	movl	%eax, %ecx      ; Подготавливаем аргумент для рекурсивного вызова (ECX = n-1)
	call	factorial       ; Рекурсивный вызов factorial(n-1)
	imull	16(%rbp), %eax  ; Умножаем результат (в EAX) на n (лежащий в стеке) = n * factorial(n-1)

.L3:                        ; Общая точка выхода:
	addq	$32, %rsp       ; Освобождаем стек
	popq	%rbp            ; Восстанавливаем предыдущий RBP
	ret                     ; Возвращаем результат
	.seh_endproc            ; Конец функции

	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"  ; Информация о компиляторе