.model small

.stack
.data 
	area1 db 500 dup(0)
	vezes dw ?
	caractere db 'A'
	cont equ lengthof area1 ;lengthof é um prefixo para retornar o tamanho de uma array
.code
.STARTUP
	lea di, area1
	mov cx, cont
	mov al, caractere
	mov vezes, 0
	cld ; limpa o diretion flag, incrmen6tando o cx nos loops envolvendo strings
continua:	repne scasb; procura o caractere armazenado em al cx vezes ou até achar uma vez o caratere
	cmp cx,0
	je fim
	inc vezes
	jmp continua
fim:        	
.EXIT
end

