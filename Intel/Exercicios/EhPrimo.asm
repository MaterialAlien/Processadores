;correto
; Verifica se var1 eh primo


.model small
divisor equ valor1
.stack
.data
valor1 dw 8
qDivisores dw ?
ehPrimo dw ?

.code

.STARTUP
	mov ehPrimo, 0
	mov qDivisores,0
	mov cx,divisor
continua:	mov ax,valor1
	mov dx, 0
	div cx ; ax/cx
	cmp dx,0; Quociente fica em ax, resto fica em dx
	jne pula; Pula a instrução seguinte se dx não é igual a 0 
	inc qDivisores
pula:	loop continua

	cmp qDivisores,2
	jne fim
	mov ehPrimo,1
fim:
.EXIT
end
	
	
		