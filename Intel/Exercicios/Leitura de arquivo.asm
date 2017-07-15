;Escrever um programa para ler um arquivo texto e apresentá-lo na tela
.model small
CR EQU 13
LF EQU 10
.stack
.data
nomeArquivo db 20 dup(?)
texto1 db "Nome do arquivo: ",CR,LF,0
texto2 db "Erro ao abrir o arquivo",CR,LF,0
texto3 db "Erro ao ler o arquivo ",CR,LF,0


.code
.STARTUP
    lea bx, texto1
    call printf_s
    
    lea bx, nomeArquivo
    mov cx, 20
    call ReadString

    lea dx,nomeArquivo
    call abreArquivo
    
    jnc erro1
    
    lea dx,nomeArquivo
    call leArquivo
    
    jnc erro2
    
    

erro1:
    lea bx,texto2
    call printf_s
    .exit
    
erro2:
    lea bx,texto3
    call printf_s
    .exit



leArquivo proc near
    mov bx, CF
    mov ah, 3ch
    mov cx 100
    int 21h
leArquivo endp
    

abreArquivo proc near
    mov ah, 3dh
    mov al,0
    int 21h
abreArquivo endp
    

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
