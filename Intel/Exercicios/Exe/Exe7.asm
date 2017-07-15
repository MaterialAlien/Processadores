.model small

.stack
.data 
	area1 db 500 dup(0)
	endereco dw ?
	caractere db 'A'
	cont equ lengthof area1 ;lengthof � um prefixo para retornar o tamanho de um array
.code
.STARTUP
	lea di, area1
	mov cx, cont
	mov al, caractere
	mov vezes, 0
	cld ; limpa o diretion flag, incrementando o cx nos loops envolvendo strings
	repne scasb; procura o caractere armazenado em al cx vezes ou at� achar uma vez o caratere
	test cx
	je coloca_null
	dec di; di=destination index. Apontador de dados usado nas opera��es envolvendo itera��o com strings, ao sair do loop o di � incrementado
	mov endereco,di
.END

colocal_null:      
	  mov endereco,0	
.EXIT
end

