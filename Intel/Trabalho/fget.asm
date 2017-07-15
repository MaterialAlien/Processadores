.model small
CR		equ		0dh
LF		equ		0ah

	.data
FileName		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)

MsgPedeArquivo		db	"Nome do arquivo: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0


.code
.STARTUP
    call pegaNome
    ;	if ( (ax=fopen(ah=0x3d, dx->FileName) ) ) {
	;		printf("Erro na abertura do arquivo.\r\n");
	;		exit(1);
	;	}
	mov		al,0
	lea		dx,FileName
	mov		ah,3dh
	int		21h
	jnc		Continua1
	
	lea		bx,MsgErroOpenFile
	call	printf_s
	
	.exit	1
	
Continua1:

	;	FileHandle = ax
	mov		FileHandle,ax		; Salva handle do arquivo
	call fget
	
	
	
    




;-------------------------------------------------------------------------
feget proc near
    lea     dx, FileBuffer
loopfget:
    mov	    bx,FileHandle
	mov	    ah,3fh
	mov	    cx,1
	int	    21h
	jnc	    Continua2
	
	lea	    bx,MsgErroReadFile
	call    printf_s
	
	mov 	al,1
	jmp	    CloseAndFinal
	
Continua2:
	;		if (ax==0) {
	;			fclose(bx=FileHandle);
	;			exit(0);
	;		}
	cmp	    ax,0
	jne	    Continua3

	mov	    al,0
	jmp	    CloseAndFinal
	
continua3:
	cmp     [dx],CR
	je      fimFget
	inc     dx
	jmp     loopfget

fimFget:	;Avança uma posição para pular o LF e ir para a próxima linha
	mov	    bx,FileHandle
	mov	    ah,3fh
	mov	    cx,1
	int	    21h
	
	ret
	
CloseAndFinal:
	mov		bx,FileHandle		; Fecha o arquivo
	mov		ah,3eh
	int		21h

Final:
	.exit
	
fget endp
;-------------------------------------------------------------------
pegaNome proc near
    ;	printf_s("Nome do arquivo: ");
	lea		bx,MsgPedeArquivo
	call	printf_s

	;	// Lê uma linha do teclado
	;	FileNameBuffer[0]=100;
	;	gets(ah=0x0A, dx=&FileNameBuffer)
	mov		ah,0ah
	lea		dx,FileNameBuffer
	mov		byte ptr FileNameBuffer,13
	int		21h

	;	// Copia do buffer de teclado para o FileName
	;	for (char *s=FileNameBuffer+2, char *d=FileName, cx=FileNameBuffer[1]; cx!=0; s++,d++,cx--)
	;		*d = *s;		
	lea		si,FileNameBuffer+2
	lea		di,FileName
	mov		cl,FileNameBuffer+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	;	// Coloca o '\0' no final do string
	;	*d = '\0';
	mov		byte ptr es:[di],0
	
	lea     bx,FileNameBuffer
	call    verificaExtensao
	
	ret
pegaNome endp

;---------------------------------------------------------------   
verificaExtensao proc near
    mov     si,0
    call    strlen
    
    add     bx,si
    
    cmp     [bx],78
    jne     colocaExtensao
    cmp     [-1+bx],73
    jne     colocaExtensao
    cmp     [-2+bx],46
    jne     colocaExtensao
    ret
verificaExtensao endp

colocaExtensao:
    mov     [bx+1],46
    mov     [bx+2],73
    mov     [bx+3],78
    mov     [bx+4],0
    ret
verificaExtensao endp
;-----------------------------------------------------------------
strlen proc near
comecoStrlen:
    cmp     [bx+si],0
    je      fimStrlen
    inc     si
    jmp     comecoStrlen
fimStrlen:
    ret
strlen endp

    