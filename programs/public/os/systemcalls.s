// Hello SysArch Class!!! Hello! Hello!

# bootup
_start:
   la t0, exception_handler        # setting up exception handler
   csrw mtvec, t0                  # ...

   # : set mepc to user_systemcalls
   la t1, user_systemcalls
   csrw mepc, t1

   # li sp, 0xffff

   mret                            # return to user mode

exception_handler:
   # : save registers you need to handle the exception
   addi   sp, sp, -128
	sw     ra,  60(sp)
	sw     t0,  56(sp)
	sw     t1,  52(sp)
	sw     t2,  48(sp)
	sw     t3,  44(sp)
	sw     t4,  40(sp)
	sw     t5,  36(sp)
	sw     t6,  32(sp)
   sw     s2,  28(sp)
   sw     s3,  24(sp)
   sw     s4,  20(sp)
   sw     s5,  16(sp)
   sw     s6,  12(sp)
   sw     s7,  8(sp)
   sw     s8,  4(sp)
   sw     s9,  0(sp)
   sw     a0,  64(sp)
   sw     a1,  68(sp)
   sw     a2,  72(sp)
   sw     a3,  76(sp)
   sw     a4,  80(sp)
   sw     a5,  84(sp)
   sw     a6,  88(sp)
   sw     a7,  92(sp)

   mv s0, a0
   csrw mepc, ra

   # : check the cause of the exception
   # t0 = mcause
   csrr t0, mcause
   srli t1, t0, 31
   bne t1, x0, exception_handler_return // if mcause[31] == 1 then its an interrupt and i ignore it
   li t1, 8
   bne t0, t1, exception_handler_return // if mcause != 8 then its not a system call and i ignore it

   # : handle the system call
   li t0, 11
   beq a7, t0, call_number_11

   li t0, 4
   beq a7, t0, call_number_4

   # if neither then ignore and return
   j exception_handler_return

   call_number_11:
   mv a0, s0
   jal ra, print_character
   j exception_handler_return


   call_number_4:
   mv a0, s0
   jal ra, print_string
   j exception_handler_return


   # : restore registers you saved and return to user mode
   exception_handler_return:
   # csrr t0, mepc
   # addi t0, t0, 4
   # csrw mepc, t0

	lw       ra,  60(sp)
	lw       t0,  56(sp)
	lw       t1,  52(sp)
	lw       t2,  48(sp)
	lw       t3,  44(sp)
	lw       t4,  40(sp)
	lw       t5,  36(sp)
	lw       t6,  32(sp)
   lw       s2,  28(sp)
   lw       s3,  24(sp)
   lw       s4,  20(sp)
   lw       s5,  16(sp)
   lw       s6,  12(sp)
   lw       s7,  8(sp)
   lw       s8,  4(sp)
   lw       s9,  0(sp)
   lw       a0,  64(sp)
   lw       a1,  68(sp)
   lw       a2,  72(sp)
   lw       a3,  76(sp)
   lw       a4,  80(sp)
   lw       a5,  84(sp)
   lw       a6,  88(sp)
   lw       a7,  92(sp)
	addi    sp,  sp,  128

   mret

wait_until_terminal_is_ready:
   la t0, terminal_ready

   wait_until_terminal_is_ready_loop:
   lbu t1, 0(t0)
   beq t1, x0, wait_until_terminal_is_ready_loop

   ret

// waits for the terminal to be ready and prints a0
print_character:
   addi sp, sp, -16
   sw a0, 0(sp)
   sw s0, 4(sp)
   sw ra, 8(sp)

   mv s0, a0

   jal ra, wait_until_terminal_is_ready
   la t0, terminal_data
   sb s0, 0(t0)

   lw a0, 0(sp)
   lw s0, 4(sp)
   lw ra, 8(sp)
   addi sp, sp, 16
   ret

// uses print_character until it reaches the null terminator
// a0 is the address of the string to print
print_string:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   // s0 = current pointer
   mv s0, a0

   # for (;;) {
   #    if (*s0 == null) {
   #       break;
   #    }

   #    print_charater (*s0)
   #    s0++;
   # }

   print_string_loop_begin:
   lbu a0, 0(s0)
   beq a0, x0, print_string_loop_end
   jal ra, print_character
   addi s0, s0, 1
   j print_string_loop_begin
   print_string_loop_end:

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret



