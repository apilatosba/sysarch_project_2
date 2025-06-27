# bootup
_start:
   la t0, exception_handler        # setting up exception handler
   csrw mtvec, t0                  # ...

   # : set mepc to user_systemcalls
   la t1, start
   csrw mepc, t1

   mret                            # return to user mode

exception_handler:
   # : save registers you need to handle the exception
   addi   sp, sp, -64
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


   call_number_4:

   # : restore registers you saved and return to user mode
   exception_handler_return:
	lw      ra,  60(sp)
	lw      t0,  56(sp)
	lw      t1,  52(sp)
	lw      t2,  48(sp)
	lw      t3,  44(sp)
	lw      t4,  40(sp)
	lw      t5,  36(sp)
	lw      t6,  32(sp)
   lw      s2,  28(sp)
   lw      s3,  24(sp)
   lw      s4,  20(sp)
   lw      s5,  16(sp)
   lw      s6,  12(sp)
   lw      s7,  8(sp)
   lw      s8,  4(sp)
   lw      s9,  0(sp)
	addi    sp,  sp,  64

   mret

wait_until_terminal_is_ready:
   # how should i do this?


