.model small

.stack

.data 
var1 db "Hello World"

.code
.STARTUP
	lea dx, var1 ; Copia endreco efetivo de var1 para dx
	mov ah, 9 ; Comando para mostrar uma string na tela com o int 21h
	int 21h ; Chama a função para printar a string var1 na tela
.EXIT
end


 