.file	"math_functions.c"  ; Исходный файл 
	.text
	.p2align 4              ; Выравнивание кода по 16-байтной границе (оптимизация)
	.globl	factorial       ; Объявляем factorial глобальной 
	.def	factorial;	.scl	2;	.type	32;	.endef  ; Директивы для отладчика
	.seh_proc	factorial   ; Начало функции с поддержкой SEH

factorial:
	.seh_endprologue        ; Упрощенный пролог (оптимизация)
	
	; Инициализация результата
	movl	$1, %eax        ; EAX = 1
	
	; Проверка базового случая (n <= 1)
	cmpl	$1, %ecx        ; Сравниваем входной аргумент (n) с 1
	jle	.L1              ; Если n <= 1, возвращаем 1 (базовый случай)

	; Цикл вычисления факториала
	.p2align 4              ; Оптимальное выравнивание для начала цикла
	.p2align 4
	.p2align 3
.L2:
	movl	%ecx, %edx      ; Сохраняем текущее n в EDX
	subl	$1, %ecx        ; Уменьшаем n на 1 (ECX = n-1)
	imull	%edx, %eax      ; Умножаем результат на n (EAX *= EDX)
	cmpl	$1, %ecx        ; Сравниваем новое n с 1
	jne	.L2              ; Если n != 1, продолжаем цикл

.L1:
	ret                     ; Возврат из функции
	.seh_endproc            ; Конец функции
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"  ; Версия компилятора