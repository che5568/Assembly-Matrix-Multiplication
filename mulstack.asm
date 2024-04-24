INCLUDE Irvine32.inc

.data

FirstDimension	byte  3
SecondDimension byte  3

M1				dword ?
M2				dword ?
MP				dword ?

promptmsg1		byte "Enter the first dimension (1-9): ", 0
promptmsg2		byte "Enter the second dimension (1-9): ", 0
errormsg		byte "Error: Please enter with the range 1-9.", 13, 10, 0

.code
main proc
	mov ebp, esp
	call Randomize					; Seed the random number generator
ask_first_again:
	mov edx, offset promptmsg1
	call WriteString				; Print "Enter the first dimension (1-9): "
	call ReadDec					; Read the first dimension
	cmp eax, 1						
	jl invalid_first_dimension		; If its less than 1, print invalid error
	cmp eax, 10						; If its between 1 and 9, its a valid dimension
	jl valid_first_dimension
invalid_first_dimension:
	mov edx, offset errormsg		
	call WriteString				; Print "Error: Please enter with the range 1-9."	
	jmp ask_first_again				; Ask first dimension again
valid_first_dimension:
	mov FirstDimension, al			; Save the first dimension
ask_second_again:
	mov edx, offset promptmsg2
	call WriteString				; Print "Enter the second dimension (1-9): "
	call ReadDec					; Read the second dimension
	cmp eax, 1						
	jl invalid_second_dimension		; If its less than 1, print invalid error
	cmp eax, 10						; If its between 1 and 9, its a valid dimension
	jl valid_second_dimension
invalid_second_dimension:
	mov edx, offset errormsg		
	call WriteString				; Print "Error: Please enter with the range 1-9."	
	jmp ask_second_again			; Ask second dimension again
valid_second_dimension:
	mov SecondDimension, al			; Save the second dimension
	mul FirstDimension				; Find FirstDimension*SecondDimension
	movzx eax, ax
	shl eax, 2						; Find FirstDimension*SecondDimension*4
	sub esp, eax					; Create a space on stack of FirstDimension*SecondDimension*4 bytes for M1
	mov M1, esp						; Save M1's address
	mov eax, 16						; Get a random number from 0 to 15
    call RandomRange
	mov edx, eax					; Save the random number
	mov al, SecondDimension
	mul FirstDimension				; Find FirstDimension*SecondDimension
	mov cx, ax
	movzx ecx, cx					; Put FirstDimension*SecondDimension in ecx. It will serve as the loop counter			
	push ecx
	mov ebx, M1
init_M1:
	mov [ebx], edx					; Initialized each element with the generated random number
	add ebx, 4						; Move on to the next element
	loop init_M1
	pop ecx
	mov esi, M1
    mov ebx, 4
    call DumpMem					; Dump M1
	mov al, SecondDimension			; Save the second dimension
	mul FirstDimension				; Find SecondDimension*FirstDimension
	movzx eax, ax
	shl eax, 2						; Find SecondDimension*FirstDimension*4
	sub esp, eax					; Create a space on stack of SecondDimension*FirstDimension*4 bytes for M2
	mov M2, esp						; Save M2's address
	mov eax, 16						; Get a random number from 0 to 15
    call RandomRange
	mov edx, eax					; Save the random number
	mov al, SecondDimension
	mul FirstDimension				; Find SecondDimension*FirstDimension
	mov cx, ax
	movzx ecx, cx					; Put SecondDimension*FirstDimension in ecx. It will serve as the loop counter			
	push ecx
	mov ebx, M2
init_M2:
	mov [ebx], edx					; Initialized each element with the generated random number
	add ebx, 4						; Move on to the next element
	loop init_M2
	pop ecx
	mov esi, M2
    mov ebx, 4
    call DumpMem					; Dump M2
	mov al, FirstDimension			
	mul FirstDimension				; Find FirstDimension*FirstDimension
	movzx eax, ax
	mov ecx, eax
	shl eax, 2						; Find FirstDimension*FirstDimension*4
	sub esp, eax					; Create a space on stack of FirstDimension*FirstDimension*4 bytes for MP
	mov MP, esp						; Save MP's address 
	mov ebx, esp
	mov edx, 0
	push ecx
init_MP:
	mov [ebx], edx					; Initialized each element with 0
	add ebx, 4						; Move on to the next element
	loop init_MP	
	pop ecx
	mov esi, MP
    mov ebx, 4
    call DumpMem					; Dump MP
	mov ebx, MP						
	mov ecx, 0						; i = 0
multiply_loop_1:
	mov esi, 0						; j = 0
multiply_loop_2:
	mov edi, 0						; k = 0
	mov [ebx], edi
multiply_loop_3:
	push ebx
	mov eax, ecx
	mov bl, SecondDimension
	movzx ebx, bl
	mul ebx
	add eax, edi
	shl eax, 2
	mov ebx, M1
	add ebx, eax
	mov eax, [ebx]			
	push eax						; Save M1[i][k] in stack
	mov eax, edi
	mov bl, FirstDimension
	movzx ebx, bl
	mul ebx
	add eax, esi
	shl eax, 2
	mov ebx, M2
	add eax, ebx
	mov ebx, [eax]					; ebx has M2[k][j]
	pop eax
	mul ebx							; Find M1[i][k]*M2[k][j]
	pop ebx
	add [ebx], eax					; MP[i][j] += M1[i][k]*M2[k][j]
	inc edi							; k++
	mov eax, edi
	cmp al, SecondDimension
	jb multiply_loop_3
	add ebx, 4
	inc esi							; j++
	mov eax, esi
	cmp al, FirstDimension
	jb multiply_loop_2
	inc ecx							; i++
	cmp cl, FirstDimension
	jb multiply_loop_1
	mov ebx, ebp
	sub ebx, esp
	shr ebx, 2
	INVOKE WriteStackFrame, 0, ebx, 0	; Print the stack frame
	exit							; Exit

main endp

end main