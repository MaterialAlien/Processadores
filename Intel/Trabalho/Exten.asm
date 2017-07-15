.model small
.stack
CR		equ		0dh
LF		equ		0ah

.data
FileName		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup(?)
novaLinha db CR,LF,0
MsgPedeArquivo		db	"Nome do arquivo: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0

sw_n	dw	0
sw_f	db	0
sw_m	dw	0


.code
.STARTUP
    
    call pegaNome
	lea bx, novaLinha
	call printf_s
	lea bx, FileNameBuffer
	call printf_s 
	.exit

	
	
 pegaNome proc near
    ;printf_s("Nome do arquivo: ");
	lea		bx,MsgPedeArquivo
	call	printf_s

		; // Lê uma linha do teclado
		; FileNameBuffer[0]=100;
		; gets(ah=0x0A, dx=&FileNameBuffer)
	lea	bx,FileNameBuffer
	call ReadString
	call verificaExtensao

	ret
pegaNome endp
;---------------------------------------------------------------   
verificaExtensao proc near
	lea bx, FileNameBuffer
	call strlen
	add bx,si
	dec bx
	
	mov al, [bx]
	cmp al,78
    jne colocaExtensao
	mov al,[-1+bx]
    cmp ax,73
    jne colocaExtensao
	mov al,[-2+bx]
    cmp al,46
    jne  colocaExtensao
    ret
colocaExtensao:
	mov byte ptr [bx+4],0 
    mov byte ptr [bx+3],'N'
    mov byte ptr [bx+2],'I'
    mov byte ptr [bx+1],'.'
    ret
verificaExtensao endp
;-----------------------------------------------------------------
strlen proc near
comecoStrlen:
	mov ax, [bx+si]
	mov ah,0
    cmp ax,0
    je fimStrlen
    inc si
    jmp comecoStrlen
fimStrlen:
    RET
strlen endp
;----------------------------------------------------------------
printf_s	proc	near

;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

;		putchar(*s)
	push	bx
	mov		ah,2
	int		21H
	pop		bx

;		++s;
	inc		bx
		
;	}
	jmp		printf_s
		
ps_1:
	ret
	
printf_s	endp
;----------------------------------------------------------------
ReadString	proc	near

		;Pos = 0
		mov		dx,0

RDSTR_1:
		;while(1) {
		;	al = Int21(7)		// Espera pelo teclado
		mov		ah,7
		int		21H

		;	if (al==CR) {
		cmp		al,0DH
		jne		RDSTR_A

		;		*S = '\0'
		mov		byte ptr[bx],0
		;		return
		ret
		;	}

RDSTR_A:
		;	if (al==BS) {
		cmp		al,08H
		jne		RDSTR_B

		;		if (Pos==0) continue;
		cmp		dx,0
		jz		RDSTR_1

		;		Print (BS, SPACE, BS)
		push	dx
		
		mov		dl,08H
		mov		ah,2
		int		21H
		
		mov		dl,' '
		mov		ah,2
		int		21H
		
		mov		dl,08H
		mov		ah,2
		int		21H
		
		pop		dx

		;		--s
		dec		bx
		;		++M
		inc		cx
		;		--Pos
		dec		dx
		
		;	}
		jmp		RDSTR_1

RDSTR_B:
		;	if (M==0) continue
		cmp		cx,0
		je		RDSTR_1

		;	if (al>=SPACE) {
		cmp		al,' '
		jl		RDSTR_1

		;		*S = al
		mov		[bx],al

		;		++S
		inc		bx
		;		--M
		dec		cx
		;		++Pos
		inc		dx

		;		Int21 (s, AL)
		push	dx
		mov		dl,al
		mov		ah,2
		int		21H
		pop		dx

		;	}
		;}
		jmp		RDSTR_1

ReadString	endp

sprintf_w	proc	near

;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instrução DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
	ret
		
sprintf_w	endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
