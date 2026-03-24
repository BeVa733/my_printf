BUF_LEN         equ 256

section .bss
printing_str:   resb BUF_LEN

section .rodata
percents_offsets:
        dq      default_handler  - percents_offsets
        dq      binary_handler   - percents_offsets
        dq      symbol_handler   - percents_offsets
        dq      decimal_handler  - percents_offsets
        dq      default_handler  - percents_offsets
        dq      float_handler    - percents_offsets
        dq      7 dup (default_handler - percents_offsets)
        dq      num_symb_handler - percents_offsets
        dq      octal_handler    - percents_offsets
        dq      poiner_handler   - percents_offsets
        dq      2 dup (default_handler - percents_offsets)
        dq      string_handler   - percents_offsets
        dq      default_handler  - percents_offsets
        dq      unsigned_handler - percents_offsets
        dq      2 dup (default_handler - percents_offsets)
        dq      hex_handler      - percents_offsets



section .data 
arg_num         db      1                           ; for function get_argument
need_prt_f      db      0                           ; for binary handler
decimal_buf     db      20 dup (0)                  ; for decimal handler
num_prt_symb    dq      0                           ; for %n handler
octal_buf       db      24 dup (0)                  ; for octal handler

section .text
global          my_printf

my_printf:
                push    rbp
                mov     rbp, rsp
                push    rbx
                push    r10
                push    r11     
                push    r12
                push    r13
                push    r14     
                push    r15

                mov     byte [rel arg_num], 1
                xor     rbx, rbx                    ; format string offset
                lea     r11, [rel printing_str]     ; temporary buffer
                xor     r12, r12                    ; temp buffer offset

.main_loop:
                movzx   eax, byte [rdi + rbx]
                test    al, al
                jz      .main_done

                cmp     al, '%'
                je      .handle_percent

                mov     byte [r11 + r12], al
                inc     rbx
                inc     r12

                cmp     r12, BUF_LEN
                jne     .main_loop
                call    print_temp_buf
                jmp     .main_loop

.handle_percent:
                inc     rbx
                mov     al, byte [rdi + rbx]
                sub     al, 'a'
                movzx   rax, al
                lea     r10, [rel percents_offsets]
                mov     rax, [r10 + 8*rax]
                add     rax, r10
                jmp     rax

.main_done:
                call    print_temp_buf
                pop     r15
                pop     r14
                pop     r13
                pop     r12
                pop     r11
                pop     r10
                pop     rbx
                pop     rbp
                ret
; ----------------------------------------------------------
; -------------- Specificator's handlers ------------------
; ----------------------------------------------------------

; -------------- Default handler --------------------------
default_handler:
float_handler:
                inc     rbx
                jmp     my_printf.main_loop

;--------------- Symbol handler ---------------------------
symbol_handler:
                call    get_argument 
                mov     byte [r11 + r12], al
                inc     r12 
                inc     rbx
                jmp     my_printf.main_loop

;--------------- Binary handler ---------------------------
binary_handler:
                call    get_argument
                mov     [rel need_prt_f], 0
                mov     r13, 64
.binloop:
                cmp     r12, BUF_LEN
                jne     .allright    
                call    print_temp_buf
.allright:
                dec     r13
                shl     rax, 1
                mov     byte [r11 + r12], '0'
                jnc     .bindone
                mov     byte [r11 + r12], '1'
                mov     [rel need_prt_f], 1
.bindone:       
                cmp     [rel need_prt_f], 0
                je      .check_cond
                inc     r12
.check_cond:
                test    r13, r13
                jnz     .binloop
                cmp     [rel need_prt_f], 0
                jne     .exit
                inc     r12 
.exit:
                inc     rbx
                jmp     my_printf.main_loop

; -------------- Decimal handler ---------------------------
decimal_handler:
                push    rbx 
                push    rdx
                call    get_argument
                lea     r10, [rel decimal_buf]
                mov     r14, r10
                mov     rbx, 10

                test    rax, rax
                jns     .no_sign
                mov     [r11 + r12], '-'
                inc     r12
                neg     rax
.no_sign:       
                xor     rdx, rdx
                div     rbx
                add     dl, '0'
                mov     [r10], dl
                inc     r10
                test    rax, rax
                jnz     .no_sign

                mov     r15, BUF_LEN
                sub     r15, r12 
                cmp     r15, 21
                ja      .write
                call    print_temp_buf
.write:
                dec     r10
                mov     al, [r10]
                mov     byte [r11 + r12], al
                inc     r12
                cmp     r14, r10
                je      .exit
                jmp     .write

.exit: 
                pop     rdx
                pop     rbx
                inc     rbx
                jmp     my_printf.main_loop 
                
; ----------- Number of symbols handler --------------------
num_symb_handler:
                call    get_argument
                push    rsi 

                mov     rsi, [rel num_prt_symb]
                add     rsi, r12 
                mov     dword [rax], esi 

                inc     rbx
                pop     rsi
                jmp     my_printf.main_loop

; ----------- Octal handler --------------------------------
octal_handler:
                push    rbx
                push    rdx
                call    get_argument

                test    rax, rax
                jnz     .not_zero
                mov     byte [r11 + r12], '0'
                inc     r12
                jmp     .exit

.not_zero:
                lea     r10, [rel octal_buf]        
                mov     r14, r10

.convert_loop:
                mov     rdx, rax                
                and     rdx, 7                  
                add     dl, '0'                
                mov     [r10], dl               
                inc     r10
                shr     rax, 3
                test    rax, rax
                jnz     .convert_loop

                mov     r15, BUF_LEN
                sub     r15, r12 
                cmp     r15, 25
                ja      .write
                call    print_temp_buf
.write:
                dec     r10
                mov     al, [r10]
                mov     byte [r11 + r12], al
                inc     r12
                cmp     r14, r10
                je      .exit
                jmp     .write


.exit:
                pop     rdx
                pop     rbx
                inc     rbx
                jmp     my_printf.main_loop

; ----------- Hex numbers handler --------------------------
hex_handler:
poiner_handler:
                push    rbx
                push    rdx
                call    get_argument

                test    rax, rax
                jnz     .not_zero
                mov     byte [r11 + r12], '0'
                inc     r12
                jmp     .exit

.not_zero:
                lea     r10, [rel octal_buf]        
                mov     r14, r10

.convert_loop:
                mov     rdx, rax                
                and     rdx, 15  
                cmp     dl,  10
                jb      .number
                add     dl, 'A'
                sub     dl, 10
                jmp     .symb_done
.number:             
                add     dl, '0'   
.symb_done:             
                mov     [r10], dl               
                inc     r10
                shr     rax, 4
                test    rax, rax
                jnz     .convert_loop

                mov     r15, BUF_LEN
                sub     r15, r12 
                cmp     r15, 25
                ja      .write
                call    print_temp_buf
.write:
                dec     r10
                mov     al, [r10]
                mov     byte [r11 + r12], al
                inc     r12
                cmp     r14, r10
                je      .exit
                jmp     .write


.exit:
                pop     rdx
                pop     rbx
                inc     rbx
                jmp     my_printf.main_loop

; ----------- unsigned handler ----------------------------
unsigned_handler:
                push    rbx 
                push    rdx
                call    get_argument
                lea     r10, [rel decimal_buf]
                mov     r14, r10
                mov     rbx, 10
                jmp     decimal_handler.no_sign
      
;------------ stirng handler -------------------------------
string_handler:
                push    rbx 
                push    rdx
                call    get_argument
                xor     rbx, rbx 
                xor     rdx, rdx
.str_pars_cycle:
                mov     bl, byte [rax + rdx]
                test    bl, bl 
                jz      .endofstr
                mov     byte [r11 + r12], bl 
                inc     r12
                cmp     r12, BUF_LEN
                jb      .skip_printing
                call    print_temp_buf 
.skip_printing: 
                inc     rdx 
                jmp     .str_pars_cycle 
.endofstr:   
                pop     rdx 
                pop     rbx 
                inc     rbx 
                jmp     my_printf.main_loop


; ----------- buffer output function -----------------------
; Entry:    RDI --> format string
;           R11 --> temporary buffer
;           R12 ==  temp buffer offset
; Exit:     R12 == 0
; Distr:    --
; ----------------------------------------------------------
print_temp_buf:
                push    rdi
                push    rsi
                push    rdx
                push    rax

                mov     rdi, 1
                lea     rsi, [r11]
                mov     rdx, r12
                mov     rax, 1
                syscall

                mov     rsi, [rel num_prt_symb]
                add     rsi, r12
                mov     qword [rel num_prt_symb], rsi

                pop     rax
                pop     rdx
                pop     rsi
                pop     rdi
                xor     r12, r12
                ret

; ----------- function for get actual argument--------------
; Entry:    [arg_num] == number of searching argument
; Exit:     RAX       == argument's value
; Distr:    R10
; Expected: RBP --> return address
;-----------------------------------------------------------
get_argument: 
                movzx   r10, byte [rel arg_num]

                cmp     r10, 5
                ja      .stack_arg

                cmp     r10, 1
                je      .reg1
                cmp     r10, 2
                je      .reg2
                cmp     r10, 3
                je      .reg3
                cmp     r10, 4
                je      .reg4
                mov     rax, r9
                jmp     .done

.reg1:          
                mov   rax, rsi
                jmp   .done
.reg2: 
                mov   rax, rdx
                jmp   .done
.reg3: 
                mov   rax, rcx
                jmp   .done
.reg4: 
                mov   rax, r8
                jmp   .done

.stack_arg:
                sub     r10, 6
                shl     r10, 3
                mov     rax, [rbp + 16 + r10]

.done:
                inc     byte [rel arg_num]
                ret


