;Corrido
;Soma os numeros pares presentes num vetor
.model small
tamanhoVetor equ lengthof vetor
.stack
.data
vetor dW 3,8,7,5,2,4,1
SomaPares dW ?

.code
.STARTUP
	mov cx, tamanhoVetor
	mov si,0
	lea bp,vetor
continua:	
	call ehPar
	cmp bx,1
	jne pula
	add si,[bp]
pula:	
	add bp,2
	loop continua
	mov SomaPares, si
.EXIT

ehPar proc near 
	mov dx, 0
	mov ax,[bp]
	mov bx,2
	div bx
	cmp dx,0
	jne retorna
	mov bx, 1
retorna: 	
	ret
ehPar endp

end
	