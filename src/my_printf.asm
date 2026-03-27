default         rel 
BUF_LEN         equ 256

section .bss
printing_str:   resb BUF_LEN
base_buf:       resb 64

section .rodata
inf:     
        dq      0x7FF0000000000000 
neg_inf: 
        dq      0xFFF0000000000000
zero: 
        dq      0.0
align 16
sign_mask: 
        dq      0x8000000000000000
ten_e6:
        dq      1000000.0
half_val: 
        dq      0.5
abs_mask:    
        dq      0x7FFFFFFFFFFFFFFF
max_float:   
        dq      9.0e18

section .data 
arg_num         db      1                           ; for function get_argument
need_prt_f      db      0                           ; for binary handler
decimal_buf     db      20 dup (0)                  ; for decimal handler
num_prt_symb    dq      0                           ; for %n handler
octal_buf       db      24 dup (0)                  ; for octal handler
xmm_arg_num     db      0                           ; to getting float argument
float_buffer    db      28 dup (0)                  ; for %f (1 - sigh, 20 - integer part, 1 - point, 6 - fractional part)

percents_offsets:
                dq      default_handler                         ; default case
                dq      binary_handler                          ; %b
                dq      symbol_handler                          ; %c
                dq      decimal_handler                         ; %d
                dq      default_handler                         ; skip
                dq      float_handler                           ; %f
                times ('n' - 'f' - 1) dq default_handler        ; skip
                dq      num_symb_handler                        ; %n
                dq      octal_handler                           ; %o
                dq      poiner_handler                          ; %p
                times ('s' - 'p' - 1) dq default_handler        ; skip
                dq      string_handler                          ; %s
                dq      default_handler                         ; skip
                dq      unsigned_handler                        ; %u
                times ('x' - 'h' - 1) dq default_handler        ; skip
                dq      hex_handler                             ; %x

regs_arguments:
                dq      float0
                dq      float1         
                dq      float2         
                dq      float3         
                dq      float4         
                dq      float5         
                dq      float6         
                dq      float7  

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
                mov     byte [rel xmm_arg_num], 0
                mov     qword [rel num_prt_symb], 0
                xor     rbx, rbx                    ; format string offset
                lea     r11, [rel printing_str]     ; temporary buffer
                xor     r12, r12                    ; temp buffer offset

.main_loop:
                movzx   eax, byte [rdi + rbx]
                test    al, al
                jz      .main_done

                cmp     al, '%'
                je      .handle_percent

                cmp     al, '\'
                je      .handle_bckslsh

                mov     byte [r11 + r12], al
                inc     rbx
                inc     r12

                cmp     r12, BUF_LEN
                jne     .main_loop
                call    print_temp_buf
                jmp     .main_loop

.handle_bckslsh:
                inc     rbx                     
                mov     al, byte [rdi + rbx]   
                cmp     al, 'n'          
                jne     .not_newline
                mov     byte [r11 + r12], 10
                jmp     .store_char
.not_newline:
                mov     byte [r11 + r12], '\'
                inc     r12 
                mov     byte [r11 + r12], al
.store_char:
                inc     r12
                inc     rbx
                jmp     .main_loop


.handle_percent:
                inc     rbx
                mov     al, byte [rdi + rbx]
                cmp     al, '%'
                je      .per_symb
                sub     al, 'a'
                movzx   rax, al
                lea     r10, [rel percents_offsets]
                jmp     [r10 + rax*8]
.per_symb:      
                mov     byte [r11 + r12], '%'
                inc     rbx
                inc     r12
                jmp     .main_loop

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
                inc     rbx
                jmp     my_printf.main_loop

;--------------- Symbol handler ---------------------------
symbol_handler:
                call    get_argument 
                mov     byte [r11 + r12], al
                inc     r12 
                inc     rbx
                jmp     my_printf.main_loop

;--------------- Bin/Oct/Hex comverter --------------------
convert_base:
                push    rbx
                push    rdx
                push    rsi
                push    rdi
                push    r10
                push    r13
        
                lea     rdi, [rel base_buf]
                mov     r14, rdi
                mov     rbx, rcx 
        
                mov     rsi, 1
                shl     rsi, cl
                dec     rsi
        
                test    rax, rax
                jnz     .convert_loop
        
                mov     byte [rdi], '0'
                inc     rdi
                jmp     .copy_to_output
        
.convert_loop:
                mov     rdx, rax
                and     rdx, rsi
                cmp     dl, 10
                jb      .digit_0_9
                add     dl, 'A' - 10
                jmp     .store_char
.digit_0_9:
                add     dl, '0'
.store_char:
                mov     [rdi], dl
                inc     rdi
                shr     rax, cl
                test    rax, rax
                jnz     .convert_loop

.copy_to_output:
                mov     r10, rdi
                dec     r10                   
.copy_loop:
                cmp     r10, r14
                jb      .done
                cmp     r12, BUF_LEN
                jne     .no_flush
                call    print_temp_buf
.no_flush:
                mov     al, [r10]
                mov     [r11 + r12], al
                inc     r12
                dec     r10
                jmp     .copy_loop

.done:
                pop     r13
                pop     r10
                pop     rdi
                pop     rsi
                pop     rdx
                pop     rbx
                ret

;-------------- Binary Handler ----------------------------
binary_handler:
                call    get_argument
                movzx   rax, eax              
                mov     rcx, 1
                call    convert_base
                inc     rbx
                jmp     my_printf.main_loop

;-------------- Octal handler -----------------------------
octal_handler:
                call    get_argument
                movzx   rax, eax
                mov     rcx, 3
                call    convert_base
                inc     rbx
                jmp     my_printf.main_loop

;-------------- Hex handler -------------------------------
hex_handler:
poiner_handler:
                call    get_argument
                movzx   rax, eax
                mov     rcx, 4
                call    convert_base
                inc     rbx
                jmp     my_printf.main_loop


; -------------- Decimal handler ---------------------------
decimal_handler:
                push    rbx 
                push    rdx
                call    get_argument
                movsx   rax, eax
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
                
; --------------- Float handler -----------------------------
float_handler:
                push    rdi 
                push    rbx
                push    rdx
                push    r13
                push    r14
                push    r15

                call    get_float_argument 
                
                lea     rdi, [rel float_buffer]
                mov     r14, rdi

                ucomisd xmm8, xmm8
                jp      .nan

                ucomisd xmm8, [rel zero]
                jae     .check_magnitude       
                
                mov     byte [rdi], '-'
                inc     rdi
                xorpd   xmm8, [rel sign_mask]

.check_magnitude:
                movsd   xmm9, [rel inf]
                ucomisd xmm8, xmm9
                je      .inf 
                
                movsd   xmm9, [rel max_float]
                ucomisd xmm8, xmm9
                jae     .inf  
        
                cvttsd2si rax, xmm8     
                cvtsi2sd  xmm9, rax 
                
                mov     r10, rdi
                mov     rbx, 10
.int_conv:
                xor     rdx, rdx
                div     rbx
                add     dl, '0'
                mov     [rdi], dl
                inc     rdi
                test    rax, rax
                jnz     .int_conv
                
                mov     r13, rdi
                dec     r13
.int_reverse:
                cmp     r10, r13
                jae     .int_done
                mov     al, [r10]
                mov     dl, [r13]
                mov     [r10], dl
                mov     [r13], al
                inc     r10
                dec     r13
                jmp     .int_reverse

.int_done:
                mov     byte [rdi], '.'
                inc     rdi

                subsd   xmm8, xmm9              
                mulsd   xmm8, [rel ten_e6]      
                addsd   xmm8, [rel half_val]    
                cvttsd2si rax, xmm8             

                mov     rcx, 6                  
                lea     rdi, [rdi + 5]          
                mov     r13, rdi                
                inc     r13
.frac_conv:
                xor     rdx, rdx
                mov     rbx, 10
                div     rbx
                add     dl, '0'
                mov     [rdi], dl
                dec     rdi
                loop    .frac_conv
                mov     rdi, r13
                jmp     .write_to_main

.nan:
                mov     rax, 'nan'
                mov     [rdi], rax
                add     rdi, 3
                jmp     .write_to_main
.inf:
                mov     rax, 'inf'
                mov     [rdi], rax
                add     rdi, 3

.write_to_main:
                mov     r13, r14                
.copy_loop:
                cmp     r13, rdi
                jae     .done
                
                cmp     r12, BUF_LEN
                jne     .no_flush
                call    print_temp_buf
.no_flush:
                mov     al, [r13]
                mov     [r11 + r12], al
                inc     r13
                inc     r12
                jmp     .copy_loop

.done:
                pop     r15
                pop     r14
                pop     r13
                pop     rdx
                pop     rbx
                pop     rdi
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
                mov     rax, [rel xmm_arg_num]
                cmp     rax, 8
                ja      .get_from_stack
                sub     rax, 8
                add     r10, rax 
.get_from_stack:
                shl     r10, 3
                mov     rax, [rbp + 16 + r10]

.done:
                inc     byte [rel arg_num]
                ret

; ----------- function for get actual float argument--------
; Entry:    [xmm_arg_num] == number of searching argument
; Exit:     XMM8 == argument's value
; Distr:    R10
; Expected: RBP --> return address
;           [arg_num] == number of ordinary argument
;-----------------------------------------------------------
get_float_argument: 
                push    rbx
                movzx   r10, byte [rel xmm_arg_num]
                cmp     r10, 7
                ja      .from_stack
                lea     rbx, [rel regs_arguments]
                jmp     [rbx + 8 * r10]
 
.from_stack:
                movzx   rbx, byte [rel arg_num]
                cmp     rbx, 6
                jb      .get_from_stack
                sub     rbx, 6
                add     r10, rbx 
.get_from_stack:
                shl     r10, 3
                movsd   xmm8, [rbp + 16 + r10]
.ret:   
                inc     byte [rel xmm_arg_num]
                pop     rbx
                ret 

float0:
                movsd   xmm8, xmm0
                jmp     get_float_argument.ret
float1:
                movsd   xmm8, xmm1
                jmp     get_float_argument.ret
float2:
                movsd   xmm8, xmm2
                jmp     get_float_argument.ret
float3:
                movsd   xmm8, xmm3
                jmp     get_float_argument.ret
float4:
                movsd   xmm8, xmm4
                jmp     get_float_argument.ret
float5:
                movsd   xmm8, xmm5
                jmp     get_float_argument.ret
float6:
                movsd   xmm8, xmm6
                jmp     get_float_argument.ret
float7:
                movsd   xmm8, xmm7
                jmp     get_float_argument.ret