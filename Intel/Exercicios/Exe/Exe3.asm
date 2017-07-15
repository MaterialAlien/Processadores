;Correto
;Soma os elementos de um vetor
.model small
tamanho equ lengthof vetor
.stack
.data 
	vetor dw 3,88,99,1,2,45
	soma dw ?
.code
.STARTUP
	mov cx, tamanho
	mov ax,0
	lea bx, vetor
 continua:
	add ax, [bx]
	add bx, 2
	loop continua
	mov soma,ax
.EXIT
end

