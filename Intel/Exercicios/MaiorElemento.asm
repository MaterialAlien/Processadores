;correto
;Calcula o maior elemnto de um vetorlink maiorele.obj
.model small

.stack

.data
greater dw ?
vetor dw 3,4,1,8,3,1,9,0
tamanho equ lengthof vetor

.code 
.STARTUP
	mov cx, tamanho
	lea bx, vetor
	mov dx,0
continua: 
	cmp [bx],dx
	jle pula
	mov dx,[bx]
pula: 	
	add bx, 2
	loop continua
	mov greater, dx

.EXIT
end
	