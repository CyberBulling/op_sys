.file	"math_functions.c"  ; Исходный файл
	.text                   ; Начало секции кода
	.p2align 4              ; Выравнивание кода по 16-байтной границе (оптимизация)
	.globl	factorial       ; Объявление символа factorial как глобального
	.def	factorial;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	factorial   ; Начало функции с SEH
factorial:
	.seh_endprologue        ; Конец пролога (отсутствует из-за оптимизации)
	movl	$1, %eax        ; EAX = 1 (начальное значение результата)

	; Проверка базового случая (n <= 1)
	cmpl	$1, %ecx        ; Сравниваем входной аргумент (n) с 1
	jle	.L1              ; Если n <= 1, прыгаем на .L1 (возвращаем 1)

	; Цикл вычисления факториала
	.p2align 4              ; Выравнивание для оптимизации цикла
	.p2align 4
	.p2align 3
.L2:
	movl	%ecx, %edx      ; Сохраняем текущее значение n в EDX
	subl	$1, %ecx        ; Уменьшаем ECX
	imull	%edx, %eax      ; Умножаем EAX на EDX (result *= n)
	cmpl	$1, %ecx        ; Сравниваем новое n с 1
	jne	.L2              ; Если n != 1, продолжаем цикл

.L1:
	ret                     ; Возвращаем результат
	.seh_endproc            ; Конец функции
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"  ; Информация о компиляторе