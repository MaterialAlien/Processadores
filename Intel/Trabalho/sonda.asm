;Rafael Júnior Ribeiro
.model small
CR		equ		0dh
LF		equ		0ah
SEPARADOR equ 59

.stack
.data
bufferCarga db 10 dup(?)
numeroConvertido db 8 dup(?)
FileHandleEntrada		dw		0				; Handler do arquivo
FileHandleSaida		dw		0				; Handler do arquivo
FileNameEntrada		db		20 dup(?)
FileNameSaida db 20 dup(?)
FileBuffer		dw 3 dup(?)
linha db 40 dup(?)
bufferTempo db 10 dup(?)
bufferDistancia db 10 dup(?)
bufferVelocidade db 10 dup(?)
valorInicialTotalCarga dw ?
valorInicialParcialCarga dw ?
valorInicialTotalDistancia dw ?
valorInicialParcialDistancia dw ?
valorFinalParcialCarga dw ?
valorFinalParcialDistancia dw ?
valorFinalParcialVelocidade dw ?
valorAtualTempo dw ?
valorAtualCarga dw ?
valorAtualDistancia dw ?
velocidadeMaxima dw 0

FileNameBuffer	db		150 dup (?)

MsgPedeArquivo		db	"Nome do arquivo de entrada: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
novaLinha db CR,LF,0

sw_n	dw	0
sw_f	db	0
sw_m	dw	0


texto1Linha1 db LF,LF,"Tempo: ",0
texto2Linha1 db " segundos",CR,LF,0
texto1Linha2 db "     Carga consumida: ",0
texto2Linha2 db " Ah",CR,LF,0
texto1Linha3 db "     Distancia percorrida: ",0
texto2Linha3 db " m",CR,LF,0
texto1Linha4 db "     Velocidade media: ",0
texto2Linha4 db " Km/h",CR,LF,0


linha6 db LF,LF,"Tempo Total: ",0
linha7 db "     Carga consumida: ",0
linha8 db "     Distancia Total: ",0
linha9 db "     Velocidade media: ",0
linha10 db "     Velocidade maxima: ",0



.code
.STARTUP

    ;pega nome do arquivo de entrada e abre
    ; if(!peganome())
		; goto continua0
	; else return 1;	
    call pegaNome
    cmp cx,1
    jne continua0
    .exit 1
continua0:
	; FILE *FileHandleEntrada=fopen(FileNameEntrada,"r");
    lea dx, FileNameEntrada
	call fopen
	mov FileHandleEntrada,ax
	
continua1:
    ;FILE *HandleEntrada=fopen(FileNameSaida,"a");
    lea dx,FileNameSaida
    call fcreate
    mov FileHandleSaida,ax


; continua2:
   ;; abre o arquivo de saida
    ; lea bx,FileNameSaida
    ; call fopen
    ; mov FileHandleSaida,ax
	
continua3:
    ;le primeira linha do arquivo
	; if(fget(linha)==2)
		; return 2;
	call fget
	cmp cx,2
	je fim_de_exec
	
	;le a segunda do arquivo
	; if(fget(linha)==2)
		; return 2;
	
    call fget
    cmp cx,1
    je fim_de_exec
	
	
	;strtok(linha);
	
	lea bx,linha
	call strtok
	
	;valorInicialTotalDistancia=valorInicialParcialDistancia=atoi(bufferDistancia);
    lea bx, bufferDistancia
    call atoi
	mov valorInicialTotalDistancia,ax
	mov valorInicialParcialDistancia,ax
	
	;valorInicialTotalCarga=valorInicialParcialCarga=atoi(bufferCarga);
    lea bx, bufferCarga
    call atoi
	mov valorInicialTotalCarga,ax
	mov valorInicialParcialCarga,ax
	
;loop até chegar no final do arquivo:
    ;lê a linha
    ;tokeniza
    ;atoi em cada um deles
    ;realiza as contas necessarias
    ;se o tempo for multiplo de 10, printa as parciais na tela, salva elas no arquivo 
    ;  e salva as novas parciais iniciais
	
	
	; while(!feof(FileHandleEntrada)
		; {
			; retorno_fget=fget(linha);
			
			; switch(retorno_fget)
			; {
				; case 1: goto continua5; break;
				; case 2: goto fim_de_exec; break;
				; case 4: goto continua6; break;
				; default:strtok(linha,bufferTempo,bufferCarga,bufferDistancia,bufferVelocidade);
				;		  processa_dados(bufferTempo,bufferCarga,bufferDistancia,bufferVelocidade); 
				;		  break;
			; }
		; }
continua4:
    call fget
	cmp cx,1
	je continua5
	cmp cx,2
	je fim_de_exec
	cmp cx,4
	je continua6
    lea bx,linha
    call strtok
	call processa_dados
    jmp continua4

	
continua5:
	;strtok(linha);
	;processa_dados();
	lea bx,linha
	call strtok
	call processa_dados
continua6:	
	;valorFinalParcialCarga=valorInicialTotalCarga-valorAtualCarga; OBS.: O valor que está na variavel é o valor da carga no instante 0
																; coloquei nessa variavel para facilicitar a programação da função que escreve os resultados
    mov ax,valorInicialTotalCarga
	sub ax, valorAtualCarga
	mov valorFinalParcialCarga,ax
	
	;valorFinalParcialDistancia=valorInicialTotalDistancia-valorAtualDistancia; OBS.: O valor que está na variavel é o valor da distancia no instante 0
																; coloquei nessa variavel para facilicitar a programação da função que escreve os resultados

	mov ax,valorInicialTotalDistancia
	sub ax,valorAtualDistancia
	mov valorFinalParcialDistancia,ax
	
	;valorFinalParcialVelocidade=valorFinalParcialDistancia/valorAtualTempo*3,6
	;OBS.: O valor multiplicado na verdade é 36, porém coloquei a parte fracionaria na parte inteira e corrigi o resultado 
	;ao escrever os resultados na tela e no arquivo de saida
	
	mov dx,0
	mov cx, 36
    imul cx
	
	mov dx,0
	mov cx,valorAtualTempo
	idiv cx
	mov valorFinalParcialVelocidade,ax
	
	;printa_rel_final;
	call printa_rel_final
	
	;fclose(FileHandleSaida);
	mov		bx,FileHandleSaida		; Fecha o arquivo
	mov		ah,3eh
	int		21h	

	;return 0;
    .exit 0
	
fim_de_exec:
	;return 4;
	.exit 4
;--------------------------------------------------------------
fget proc near
;int fget(linha)
;	{
	;di=0;
	;do
		;{
			;FileBuffer=fgetc(FileHandleEntrada);
			; if (CF)
				; {
					; printf("Erro ao ler o arquivo");
					; fclose(FileHandleEntrada);
					; return 2;
				; }
			; else if(FileBuffer==CR)
				; {
					; linha[di]='\n';
					; return 3;
				 ;}
			; else if(FileBuffer == EOF)
				; {
					; fclose(FileHandleEntrada);
					; if (di==0) return 4;
					; else 
						; {
							; linha[di]='\n';
							; return 1;
						; }
				; }
			; di++;
		; }while (FileBuffer !='\n');
	;}
	
	mov di,0

Again:	
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	mov		bx,FileHandleEntrada
	int		21h
	jnc	Continua_f2
	
	
	lea bx, novaLinha
	call printf_s
	lea		bx,MsgErroReadFile
	call	printf_s
		
	mov		al,1
	jmp		CloseAndFinal

Continua_f2:
	mov cx, FileBuffer
	cmp cx,13
	je FimDaLinha
	cmp	ax,0
	jne	Continua_f3
	mov	al,0
	mov byte ptr [bx+di],0
	jmp	FimDoArquivo

Continua_f3:
	lea bx,linha
	mov ax, FileBuffer
	mov [bx+di],ax
	inc di
	
	jmp		Again

FimDoArquivo:
	cmp di,0
	je FimDoArquivo2
	mov		bx,FileHandleEntrada		; Fecha o arquivo
	mov		ah,3eh
	int		21h	
	mov cx,1
	ret
	
CloseAndFinal:
	mov		bx,FileHandleEntrada		; Fecha o arquivo
	mov		ah,3eh
	int		21h	
	mov cx,2
	ret

FimDaLinha:
	lea bx, linha
	mov byte ptr [bx+di],0;Move o caractere lido para a string linha e incrementa o indice da linha
	
	;Pula o LF
	mov		bx,FileHandleEntrada
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov cx,3
	ret
	
FimDoArquivo2:
	mov		bx,FileHandleEntrada		; Fecha o arquivo
	mov		ah,3eh
	int		21h	
	mov cx,4
	ret
fget endp	
;----------------------------------------------------------------------
strtok proc near
	;strtok(char bufferTempo, bufferCarga,bufferDistancia,bufferVelocidade)
	;{
	; bufferTempo=strtok(linha,';');
	; bufferCarga=strtok(NULL,';');
	; bufferDistancia=strtok(NULL,';');
	; bufferVelocidade=strtok(NULL,';');
	;}

	lea bp, bufferTempo
	call strtok2
	lea bp, bufferCarga
	call strtok2
	lea bp, bufferDistancia
	call strtok2
	lea bp, bufferVelocidade
	call strtok2
	
	lea bx, bufferCarga
	mov al,[bx+1]
    cmp al,','
    je cargaAbaixode1
	mov al,[bx+2]
	cmp al,','
	je cargaAcimade10
	
;Carga entre 1 e 10
	mov dl,[bx+3]
    mov [bx+2],dl
    mov byte ptr [bx+3],0
    ret
;Carga abaixo de 1    
cargaAbaixode1:
	mov dl,[bx+2]
    mov [bx+1],dl
    mov byte ptr [bx+2],0
	ret
;Carga acima de 10	
cargaAcimade10:
	int 3
	mov dl,byte ptr [bx+3]
	mov byte ptr [bx+2],dl
	mov byte ptr [bx+3],0
	ret

strtok endp
;-----------------------------------
	
strtok2 proc near
continua_strtok2:
	mov al,[bx]
	cmp al,';'
	je fim_strtok2
	cmp al,0
	je fim_strtok2
	mov dl,al
	mov [bp],dl
	inc bx
	inc bp
	jmp continua_strtok2
fim_strtok2:
    mov byte ptr [bp],0
    inc bx
    ret

strtok2 endp
;----------------------------------------------------------------------

processa_dados proc near

	;processa_dados(int bufferVelocidade,bufferCarga,bufferDistancia,bufferTempo)
	;{
	; ax=atoi(bufferVelocidade);
	; if(ax>valocidadeMaxima)
	; 		valocidadeMaxima=ax;
	; valorAtualCarga=atoi(bufferCarga);
	; valorAtualDistancia=atoi(bufferDistancia);
    ; valorAtualTempo=atoi(bufferTempo);
	; if((valorAtualTempo%10)==0)
	;	{
	;       valorInicialParcialDistancia=valorInicialParcialDistancia-valorAtualDistancia;
	;       valorInicialParcialCarga=valorInicialParcialCarga-valorAtualCarga;
	;		valoFinalParcialVelocidade=valorInicialParcialDistancia/valorAtualTempo*3,6
	;		;obs.: O valor multiplicado é 36 mas é corrigido na printagem
	;	
	;	;escreve(FileHandleSaida,valorAtualTempo,valorInicialParcialDistancia,valorInicialParcialCarga,valorFinalParcialVelocidade);
	;	}
	;}  
    lea bx, bufferVelocidade
    call atoi
    cmp ax, velocidadeMaxima
    jle continua_processa_dados
    mov velocidadeMaxima, ax

continua_processa_dados:  
	lea bx,bufferCarga
    call atoi
    mov valorAtualCarga,ax
	
	lea bx, bufferDistancia
    call atoi
    mov valorAtualDistancia, ax
			
    lea bx,bufferTempo
    call atoi
    mov valorAtualTempo,ax
    mov cx,10
    idiv cx
    cmp dx,0
    je seta_valores_parciais
    ret

seta_valores_parciais:
;Distancia
	mov ax,valorAtualDistancia
    mov dx, valorInicialParcialDistancia
    sub dx,ax
    mov valorFinalParcialDistancia,dx
    mov valorInicialParcialDistancia,ax
;Carga 
	mov ax,valorAtualCarga
    mov dx, valorInicialParcialCarga
    sub dx, ax
    mov valorFinalParcialCarga,dx
    mov valorInicialParcialCarga,ax
;Velocidade   
    mov ax,valorFinalParcialDistancia
    mov cx, 36
    imul cx
    mov cx,10
    mov dx,0
    idiv cx
    mov valorFinalParcialVelocidade,ax
    
    call escreve_dados
	
    ret
processa_dados endp
;---------------------------------------------------------
 escreve_dados proc near

	; escreve_dados(FILE FileHandleSaida, int valorAtualTempo,ValorFinalVelocidade,float valorInicialParcialCarga,valorInicialParcialDistancia)
	; {
	;    printf("Tempo: %d segundos\n    Carga consumida: %f Ah\n",valorAtualTempo,valorInicialParcialCarga);
	;    printf("    Distancia percorrida: %d\n    Velocidade media: %f\n\n", valorInicialParcialDistancia,ValorFinalVelocidade);
	;    fprintf(FileHandleSaida,"%d;%f,%d,%f\n",valorAtualTempo, valorInicialParcialCarga,valorInicialParcialDistancia,valorFinalParcialVelocidade);
	; }
		
	

;Tempo
    lea bx, texto1Linha1
    call printf_s
    lea bx, bufferTempo
    call printf_s
    lea bx, texto2Linha1
    call printf_s
	lea bp,linha
	lea bx, bufferTempo
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, bufferTempo
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h	
	
;Carga
    lea bx, texto1Linha2
    call printf_s
    lea bx, numeroConvertido
    mov ax, valorFinalParcialCarga
    call sprintf_w
	cmp valorFinalParcialCarga,100
	jge maiorque10
    cmp valorFinalParcialCarga,10
    jge maiorque1
	lea bx,numeroConvertido
    mov byte ptr [bx+3],0
	mov dl,[bx]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx],'0'
    jmp continua_printar_carga
maiorque1:
	lea bx,numeroConvertido
	mov dl,[bx+1]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx+3],0
	jmp continua_printar_carga
maiorque10:
	lea bx, numeroConvertido
	mov dl,byte ptr [bx+2]
	mov byte ptr [bx+3],dl
	mov byte ptr [bx+2],','
	mov byte ptr [bx+4],0	
continua_printar_carga:
    call printf_s
    lea bx,texto2Linha2
    call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Distancia
    lea bx, texto1Linha3
    call printf_s
    lea bx, numeroConvertido
    mov ax, valorFinalParcialDistancia
    call sprintf_w
    lea bx,numeroConvertido
    call printf_s
    lea bx,texto2Linha3
    call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Velocidade
    lea bx,texto1Linha4
    call printf_s
    lea bx,numeroConvertido
    mov ax, valorFinalParcialVelocidade
    call sprintf_w
	
	cmp valorFinalParcialVelocidade,10
    jge maiorque1_vel
	lea bx,numeroConvertido
	call strlen
	dec si
	add bx,si
	mov dl,byte ptr [bx]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx],'0'
	mov byte ptr [bx+3],0
    jmp continua_printar_vel
maiorque1_vel:
	lea bx,numeroConvertido
	call strlen
	dec si
	add bx,si
	mov dl,byte ptr [bx]
    mov byte ptr [bx+1],dl
    mov byte ptr [bx],','
    mov byte ptr [bx+2],0
continua_printar_vel:
    lea bx, numeroConvertido
    call printf_s
    lea bx, texto2Linha4
    call printf_s
	
	lea bx, novaLinha
	call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],CR
	mov byte ptr [bx+si+1],LF
	mov cx,si
	add cx,2
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
    
    ret
    
escreve_dados endp

;------------------------------------------------------------------------    
fopen	proc	near
	mov		al,2
	mov		ah,3dh
	int		21h
	jnc		continua_fopen
	
	lea		bx,MsgErroOpenFile
	call	printf_s
	.exit	1
	
continua_fopen:
	ret
fopen	endp
;---------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	jnc		continua_fcreate
	
	lea		bx,MsgErroOpenFile
	call	printf_s
	.exit	2
	
continua_fcreate:
	ret
fcreate	endp
;-------------------------------------------------------------------------
pegaNome proc near
    ;pegaNome(FileNameEntrada,FileNameSaida)
	;{
	;	printf("Digite o nome do arquivo:");
	;	gets(FileNameEntrada);
	;	
	;	si=strlen(FileNameEntrada);
	;	if((FileNameEntrada[si]!='n' && FileNameEntrada[si]!='N' ) 
	;		|| (FileNameEntrada[si-1]!='i' && FileNameEntrada[si-1]!='I' )
	;		|| (FileNameEntrada[si-2]!='.'))
	;		{
	;			FileNameEntrada[si+1]='.';
	;			FileNameEntrada[si+2]='i';
	;			FileNameEntrada[si+3]='n';
	;			FileNameEntrada[si+4]='\n';
	;		}
	;		
	;	strcpy(FileNameSaida,FileNameEntrada);
	;	si=FileNameSaida;
	;	FileNameSaida[si-1]='o';
	;	FileNameSaida[si]='u';
	;	FileNameSaida[si+1]='t';
	;	FileNameSaida[si+2]='\n';
	;}
						
	lea		bx,MsgPedeArquivo
	call	printf_s

	mov		ah,0ah						
	lea		dx,FileNameEntrada
	mov		byte ptr FileNameEntrada, 20
	int		21h
	jnc continuapegaNome1
	lea bx, MsgErroOpenFile
	call printf_s
	mov cx,1
	ret
continuapegaNome1:
	lea		si,FileNameEntrada+2					
	lea		di,FileNameEntrada
	mov		cl,FileNameEntrada+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0	
		
	call verificaExtensao
	
	lea bx, FileNameEntrada
	call pegaNomeSaida
	
	mov cx,0

	ret
pegaNome endp
;---------------------------------------------------------------   
verificaExtensao proc near
	lea bx, FileNameEntrada
	mov si,0
	call strlen
	add bx,si
	dec bx
	
	mov al, [bx]
	cmp al,'N'
    je continua_verifica_exten1
    cmp al,'n' 
    je continua_verifica_exten1
    jmp colocaExtensao

continua_verifica_exten1:  
	mov al, [bx-1]
    cmp al,'I'
    je continua_verifica_exten2
    cmp al,'i' 
    je continua_verifica_exten2
    jmp colocaExtensao
    
continua_verifica_exten2:  
	mov al,[bx-2]
    cmp al,'.'
    je continua_verifica_exten3
    jmp colocaExtensao

continua_verifica_exten3:
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
	mov si,0
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
pegaNomeSaida proc near
    call strlen
    sub si,3
    mov cx,si
    lea bp, FileNameSaida
loopPegaNomeSaida:
	mov al,[bx]
    mov [bp],al
    inc bp
    inc bx
    loop loopPegaNomeSaida
	
    
    mov byte ptr [bp+4],0
    mov byte ptr [bp+3],'T'
    mov byte ptr [bp+2],'U'
    mov byte ptr [bp+1],'O'
	mov byte ptr [bp],'.'
	
	ret
	

pegaNomeSaida endp

;------------------------------------------------
printa_rel_final proc near

	; printa_rel_final(FILE FileHandleSaida, int valorAtualTempo,valorFinalParcialDistancia,float valorFinalParcialCarga,ValorFinalVelocidade,VelocidadeMaxima)
	; {
	;    printf("Tempo Total: %d segundos\n    Carga consumida: %f Ah\n",valorAtualTempo,valorFinalParcialCarga);
	;    printf("    Distancia total: %d\n    Velocidade media: %f\n", valorInicialParcialDistancia,ValorFinalVelocidade);
	;	 printf("    Velocidade Maxima: %d", velocidadeMaxima);
	;    fprintf(FileHandleSaida,"%d;%f,%d,%f,%d",valorAtualTempo, valorInicialParcialCarga,valorInicialParcialDistancia,valorFinalParcialVelocidade,VelocidadeMaxima);
	; }

;Tempo
    lea bx, linha6
    call printf_s
	lea bx, bufferTempo
	mov ax,valorAtualTempo
	call sprintf_w
    lea bx, bufferTempo
    call printf_s
    lea bx, texto2Linha1
    call printf_s
	
	lea bp,linha
	lea bx, bufferTempo
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, bufferTempo
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Carga
    lea bx, linha7
    call printf_s
    lea bx, numeroConvertido
    mov ax, valorFinalParcialCarga
    call sprintf_w
	cmp valorFinalParcialCarga,100
	jge maiorque10_
    cmp valorFinalParcialCarga,10
    jge maiorque1_
	lea bx,numeroConvertido
    mov byte ptr [bx+3],0
	mov dl,[bx]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx],'0'
    jmp continua_printar_carga_
maiorque1_:
	lea bx,numeroConvertido
	mov dl,[bx+1]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx+3],0
	jmp continua_printar_carga_
maiorque10_:
	lea bx, numeroConvertido
	mov dl,byte ptr [bx+2]
	mov byte ptr [bx+3],dl
	mov byte ptr [bx+2],','
	mov byte ptr [bx+4],0
continua_printar_carga_:
    call printf_s
    lea bx,texto2Linha2
    call printf_s
	
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Distancia
    lea bx, linha8
    call printf_s
    lea bx, numeroConvertido
    mov ax, valorFinalParcialDistancia
    call sprintf_w
    lea bx,numeroConvertido
    call printf_s
    lea bx,texto2Linha3
    call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Velocidade
    lea bx,linha9
    call printf_s
    lea bx,numeroConvertido
    mov ax, valorFinalParcialVelocidade
    call sprintf_w
	
	cmp valorFinalParcialVelocidade,10
    jge maiorque1_vel_
	lea bx,numeroConvertido
	call strlen
	dec si
	add bx,si
	mov dl,byte ptr [bx]
    mov byte ptr [bx+2],dl
    mov byte ptr [bx+1],','
    mov byte ptr [bx],'0'
	mov byte ptr [bx+3],0
    jmp continua_printar_vel_
maiorque1_vel_:
	lea bx,numeroConvertido
	call strlen
	dec si
	add bx,si
	mov dl,byte ptr [bx]
    mov byte ptr [bx+1],dl
    mov byte ptr [bx],','
    mov byte ptr [bx+2],0
continua_printar_vel_:		
    lea bx, numeroConvertido
    call printf_s
    lea bx, texto2Linha4
    call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov byte ptr [bx+si],';'
	mov cx,si
	inc cx
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
	
;Velocidade máxima	
	lea bx, numeroConvertido
	mov ax, velocidadeMaxima
	call sprintf_w
	lea bx, linha10
	call printf_s
	lea bx, numeroConvertido
	call printf_s
	lea bx, texto2Linha4
	call printf_s
	
	lea bx, numeroConvertido
	call strlen
	mov cx,si
	lea dx, numeroConvertido
	mov bx, FileHandleSaida
	mov ah,40h
	int 21h
   
	ret
printa_rel_final endp
;----------------------------------------------------
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

;--------------------------------------------------------------------
;====================================================================
; ReadString
;	- Escrever uma rotina para ler um string do teclado
;	- O ponteiro para o string entra em DS:BX
;	- O número máximo de caracteres a serem lidos (e colocados
;		no buffer do string) entra em CX
;	- Deve considerar o CR (0x0D) como final da entrada do string
;	- Deve processar BS (back space), código ASCII 0x08
;	- Quando chegar ao final do string, ignorar qualquer nova 
;		tecla digitada
;	- Um string é uma seqüência de caracteres ASCII que termina
;		com 00H (‘\0’)
;====================================================================
;Função: Lê um string do teclado
;Entra: (S) -> DS:BX -> Ponteiro para o string
;	    (M) -> CX -> numero maximo de caracteres aceitos
;Algoritmo:
;	Pos = 0
;	while(1) {
;		al = Int21(7)	// Espera pelo teclado
;		if (al==CR) {
;			*S = '\0'
;			return
;		}
;		if (al==BS) {
;			if (Pos==0) continue;
;			Print (BS, SPACE, BS)	// Coloca 3 caracteres na tela
;			--S
;			++M
;			--Pos
;		}
;		if (M==0) continue
;		if (al>=SPACE) {
;			*S = al
;			++S
;			--M
;			++Pos
;			Int21 (s, AL)	// Coloca AL na tela
;		}
;	}
;--------------------------------------------------------------------
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
;--------------------------------------------------------------------------------------------------------------
;====================================================================
;	- Escrever uma rotina para converter um número com 16 bits em um string
;	- O valor de 16 bits entra no registrador AX
;	- O ponteiro para o string entra em DS:BX
;	- Um string é uma seqüência de caracteres ASCII que termina com 00H (‘\0’)
;====================================================================
;dados exclusivos
; string_tamanho db 10 dup(?)
; H2D		db	10 dup (?)

; sw_n	dw	0
; sw_f	db	0
; sw_m	dw	0
;--------------------------------------------------------------------
;Função: Converte um inteiro (n) para (string)
;		 sprintf(string, "%d", n)
;
;void sprintf_w(char *string->BX, WORD n->AX) {
;	k=5;
;	m=10000;
;	f=0;
;	do {
;		quociente = n / m : resto = n % m;	// Usar instrução DIV
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
;		n = resto;
;		m = m/10;
;		--k;
;	} while(k);
;
;	if (!f)
;		*string++ = '0';
;	*string = '\0';
;}
;
;Associação de variaveis com registradores e memória
;	string	-> bx
;	k		-> cx
;	m		-> sw_m dw
;	f		-> sw_f db
;	n		-> sw_n	dw
;--------------------------------------------------------------------
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
	mov		byte ptr [bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
	ret
		
sprintf_w	endp
;--------------------------------------
atoi	proc near

		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		ret

atoi	endp

    end
    
    
    
    
    
    
    
    
    
    
    
    

