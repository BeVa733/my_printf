BUF_LEN         equ 256

section .bss
printing_str:   resb BUF_LEN

section .rodata
percents_offsets:
        dq      default_handler - percents_offsets
        dq      binary_handler  - percents_offsets
        dq      symbol_handler  - percents_offsets

section .data 
arg_num         db      1                           ; for function get_argument
need_prt_f      db      0                           ; for binary handler



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

                xor     rbx, rbx                    ; смещение в строке формата
                lea     r11, [rel printing_str]     ; временный буфер
                xor     r12, r12                    ; смещение в буфере

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

; ---- обработчики спецификаторов ----
default_handler:
symbol_handler:
                inc     rbx
                jmp     my_printf.main_loop

;--------------- Binary heandler ---------------------------

binary_handler:
                call    get_argument
                mov     [rel need_prt_f], 0
                mov     r13, 64
.binloop:
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


; ----------- buffer output function -----------------------
; Entry:    RDI --> format string
;           R11 --> temporary buffer
;           R12 ==  temp buffer offset
; Exit:     R12 == 0
; Distr:    RAX
; ----------------------------------------------------------
print_temp_buf:
                push    rdi
                push    rsi
                push    rdx
                mov     rdi, 1
                lea     rsi, [r11]
                mov     rdx, r12
                mov     rax, 1
                syscall
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


