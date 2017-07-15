.model small
CR		equ		0dh
LF		equ		0ah

.stack
.data
FileName		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)

MsgPedeArquivo		db	"Nome do arquivo: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0

novaLinha db CR,LF,0
vetorEnderecos dw offset palavra4,offset palavra3, offset palavra2,offset palavra1

exemplo db "54;23;875;68",CR,LF,0
sw_n	dw	0
sw_f	db	0
sw_m	dw	0
palavra1 db 10 dup(?)
palavra2 db 10 dup(?)
palavra3 db 10 dup(?)
palavra4 db 10 dup(?)

.code
.STARTUP
	lea bx, FileName
	call ReadString
	lea bx, FileName
	call strtok
	lea bx, novaLinha
	call printf_s
	lea bx, byte ptr palavra1
	call printf_s
	lea bx, novaLinha
	call printf_s
	lea bx, novaLinha
	lea bx, byte ptr palavra2
	call printf_s
	lea bx, novaLinha
	call printf_s
	lea bx, byte ptr palavra3
	call printf_s
	lea bx, novaLinha
	call printf_s
	lea bx, byte ptr palavra4
	call printf_s
.exit
	
	
	
strtok proc near
	mov cx,4
	mov si,6
	lea bp, vetorEnderecos
loop_strtok:
	mov di, [bp+si]
continua_strtok:
	mov al,[bx]
	cmp al,59
	je avanca
	cmp al,0
	je fim_strtok
	mov [di],al
	inc bx
	inc di
	jmp continua_strtok
avanca:
	inc bx
	sub si,2
	loop loop_strtok
fim_strtok:
	ret
strtok endp
;---------------------------------------------------

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
;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
	
	
	
	
	