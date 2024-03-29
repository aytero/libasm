;int	ft_atoi_base(char *str, char *base);

global _base_check
section .text

_base_check:
		push rbp
		mov rbp, rsp
		push r12
		push rbx

		xor rdx, rdx
		mov rbx, -1					; base_len = -1 (base str index counter)
.inc_base_check:
		inc rbx						; base_len++
		mov dl, byte [rsi + rbx]	; copy byte in dl
		cmp dl, 0					; check for '\0'
		je .check_base_len
		cmp dl, 32					; *str == sp ?
		je .error
		cmp dl, 9					; *str == ht ?
		je .error
		cmp dl, 10					; *str == nl ?
		je .error
		cmp dl, 11					; *str == vt ?
		je .error
		cmp dl, 12					; *str == np ?
		je .error
		cmp dl, 13					; *str == cr ?
		je .error
		cmp dl, 43					; *str == '+' ?
		je .error
		cmp dl, 45					; *str == '-' ?
		je .error

		mov rcx, rbx				; rcx = rbx
.check_base_double:					; cmp dl with every other base char
		inc rcx
		cmp byte [rsi + rcx], 0		; check for '\0'
		je .inc_base_check
		cmp byte [rsi + rcx], dl	; cmp dl and rsi[rcx]
		je .error					; base contains the same char twice
		jmp .check_base_double

.check_base_len:
		cmp rbx, 1					; rbx > 1 ?
		jl .error					; if less - error
		jmp .end

.error:
		xor rbx, rbx				; base_len = 0

.end:
		mov rax, rbx
		pop rbx
		pop r12
		mov rsp, rbp
		pop rbp
		ret							; return base_len


global	_ft_atoi_base
section	.text

_ft_atoi_base:

		push rbp
		mov rbp, rsp
		push r12
		push rbx

		test rdi ,rdi				; check args:
		jz _error					; rdi == null ?
		test rsi, rsi				; rsi == null ?
		jz _error

		call _base_check
		test rax, rax				; check func return (base_len)
		jz _error
		mov rbx, rax				; rbx = base_len

		xor rax, rax				; rax = 0 (value)
		xor r12, r12				; r12 = 0 (num of '-')
		mov rcx, -1					; rcx = -1 (str index counter)
.skip_spaces:
		inc rcx
		cmp byte [rdi + rcx], 32	; *str == sp ?
		je .skip_spaces
		cmp byte [rdi + rcx], 9		; *str == ht ?
		je .skip_spaces
		cmp byte [rdi + rcx], 10	; *str == nl ?
		je .skip_spaces
		cmp byte [rdi + rcx], 11	; *str == vt ?
		je .skip_spaces
		cmp byte [rdi + rcx], 12	; *str == np ?
		je .skip_spaces
		cmp byte [rdi + rcx], 13	; *str == cr ?
		je .skip_spaces
		jmp short .inc_sign

.inc_str_counter:
		inc rcx
.inc_sign:
		cmp byte [rdi + rcx], 45	; *str == '-' ?
		jne .skip_sign
		inc r12						; inc '-' counter
.skip_sign:
		cmp byte [rdi + rcx], 43	; *str == '+' ?
		je .inc_str_counter
		cmp byte [rdi + rcx], 45	; *str == '-' ?
		je .inc_str_counter
		jmp short .atoi_loop

.atoi_inc:
		inc rcx
.atoi_loop:
		cmp byte [rdi + rcx], 0
		je .set_sign

		mov r9, -1					; set base index counter
		xor rdx, rdx
.search_base_index:
		inc r9
		mov dl, byte [rsi + r9]		; copy base str byte in dl
		cmp dl, 0					; check for '\0'
		je .set_sign
		cmp byte [rdi + rcx], dl	; cmp str symbol with base symb
		jne .search_base_index

.calc:
		; rax = rax * base_len + index in base
		mul rbx						; rax = rax * rbx
		add rax, r9					; rax = rax + r9
		jmp short .atoi_inc

 .set_sign:
		test r12, 1					; check if amount of '-' is even or odd
		jz _end						; if even
		neg rax						; if odd rax = -rax
		jmp short _end

_error:
		xor rax, rax				; set rax 0

_end:
		pop rbx
		pop r12
		mov rsp, rbp
		pop rbp
		ret
