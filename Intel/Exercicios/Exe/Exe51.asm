.model small

.stack
.data 
	area1 dw 2,4,3
	area2 dw 3 DUP(99)
	cont dw 3 ;lengthof é um prefixo para retornar o tamanho de uma array
.code
.STARTUP
	lea si, area1
	lea di, area2
	mov cx, cont
	cld ; limpa o diretion flag, incrmen6tando o cx nos loops envolvendo strings
	rep movsw; move cada caractere da area1 para area2 cx vezes
.EXIT
end

