;Correto
;Move os dados de uma area de bytes para outra
.model small

.stack
.data 
	area1 dw  3,8,9
	area2 dw 3 dup(88) 
	cont equ lengthof area1 ;lengthof é um prefixo para retornar o tamanho de uma array
	valor dw ?
.code
.STARTUP
	lea bp, area1
	lea bx, area2
	mov cx, cont
continua:	
	mov ax, [bp]
	mov [bx],ax
	add bp,2
	add bx,2
	loop continua
.EXIT
end

