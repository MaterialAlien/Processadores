.model small

.stack
.data 
	var1 dw 5
	var2 dw 8
	var3 dw 2 dup(0)
.code
.STARTUP
	mov ax,var1 ; Qaulqeur um dos operandos vai para ax sempre
	mul var2      ; multiplica pelo outro operando
	mov var3,ax ; 2 byte menos significativo do produto ficam em ax
	mov var3+2,dx ; 2 byte mais significativo do produto ficam em dx
.EXIT
end

