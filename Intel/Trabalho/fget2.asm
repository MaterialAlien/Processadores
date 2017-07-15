.model small
CR		equ		0dh
LF		equ		0ah

.stack
.data
FileNameEntrada		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db	;;	10 dup (?)		; Buffer de leitura do arquivo
FileHandleEntrada		dw		0				; Handler do arquivo
FileHandleSaida		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)

FileNameEntradaExemplo "exemplo.IN",0

MsgPedeArquivo		db	"Nome do arquivo de entrada: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0

novaLinha db CR,LF,0
vetorEnderecos dw offset palavra4,offset palavra3, offset palavra2,offset palavra1

linha db 100 dup(?)
palavra1 db 10 dup(?)
palavra2 db 10 dup(?)
palavra3 db 10 dup(?)
palavra4 db 10 dup(?)
sw_n	dw	0
sw_f	db	0
sw_m	dw	0

.code
.STARTUP
    call fget
    
    
fget proc near
    push offset linha
continua_fget:
    mov		bx,FileHandleEntrada
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	jnc		Continua2
	
	lea		bx,MsgErroReadFile
	call	printf_s
	
	mov		al,1
	jmp		CloseAndFinal

Continua2:
	;		if (ax==0) {
	;			fclose(bx=FileHandle);
	;			exit(0);
	;		}
	cmp		ax,0
	jne		Continua3
	jmp		FinalDeArquivo

Continua3:
	;		printf("%c", FileBuffer[0]);	// Coloca um caractere na tela
	mov		ah,2
	mov		dl,FileBuffer
	int		21h
	
	cmp FileBuffer,CR
	je fimDeLinha
	pop bx
	mov [bx],FileBuffer
	inc bx
	push bx
	jmp		continua_fget
	
fimDelinha:
    mov cx,0
    ret
FimDeArquivo:
    mov cx,1
    ret
CloseAndFinal:
    .exit
fget endp
	
	
	
	
	
	
	
	
	
	
	
	