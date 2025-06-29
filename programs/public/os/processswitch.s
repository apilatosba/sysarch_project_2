// idk man. there is no mmu so how can i make sure that two user processes don't interfere with each other?
// i am just gonna assume that they dont. and i am gonna use my given range 0x0 to 0xffff and i am gonna assume
// user processes dont use that range.

// i couldnt make .equ work
# .equ PCB_ADDRESS, 0x0010 // not zero because otherwise idk it looks like a null pointer
# .equ PCB_SIZE, 128 // just enough for 32 registers. instead of x0 i store the pc and pc goes to the end
# .equ PROCESS_COUNT, 2
# .equ PROCESS_ID_ADDRESS, 0x0 // either 1 or 0. 0 means fibonacci, 1 means the other one that i forgot the name of

# : set up exception handler
la t0, exception_handler        # setting up exception handler
csrw mtvec, t0                  # ...

# : set up mepc to point to the first instruction of the fibonacci function
la t0, fibonacci
csrw mepc, t0

# : enable and set up interrupts as needed

// mtimecmp = mtime + 300
la t0, mtime
lw t1, 0(t0)
lw t2, 4(t0)

mv a0, t1
mv a1, t2
li a2, 300
jal ra, add_64_bit

li t0, -1
la t1, mtimecmp
sw t0, 0(t1)
sw a1, 4(t1)
sw a0, 0(t1)

li t0, 128 // 7th bit is on. 1 << 7
csrr t1, mie
or t1, t1, t0
csrw mie, t1

# li t0, 8 // 0b1000
# csrr t1, mstatus
# or t1, t1, t0
# csrw mstatus, t1

# : set up data structures for process control blocks
li t0, 0 // PROCESS_ID_ADDRESS
sw x0, 0(t0) // fibonacci
li sp, 0xffff

la t0, factorial
// save factorial pc. pc location = PCB_ADDRESS + 1 * PCB_SIZE + offset of 124
li t1, 0x10 // PCB_ADDRESS
addi t1, t1, 128 // PCB_SIZE
sw t0, 124(t1)

li t0, -6145 // ~((1 << 11) | (1 << 12))
csrr t1, mstatus
and t1, t1, t0
csrw mstatus, t1

# : execute the fibonacci function until you get an interrupt
mret


exception_handler:
   # : save some registers
   # addi sp, sp, -16 // using a little bit space on the user process memory. surely thats okay to do Clueless
                      // do not modify registers
   # sw t0, -16(sp)
   # sw t1, -12(sp)
   # sw t2, -8(sp)
   # sw t3, -4(sp)

   csrrw x0, mscratch, t0

   li t0, 0 // PROCESS_ID_ADDRESS
   lw t0, 0(t0)
   // pcb address = PCB_ADDRESS + t0 * PCB_SIZE
   slli t0, t0, 7 // PCB_SIZE
   addi t0, t0, 0x10 // PCB_ADDRESS

   sw x1, 0(t0)
   sw x2, 4(t0)
   sw x3, 8(t0)
   sw x4, 12(t0)
   sw x5, 16(t0) // t0 needs be resaved
   sw x6, 20(t0)
   sw x7, 24(t0)
   sw x8, 28(t0)
   sw x9, 32(t0)
   sw x10, 36(t0)
   sw x11, 40(t0)
   sw x12, 44(t0)
   sw x13, 48(t0)
   sw x14, 52(t0)
   sw x15, 56(t0)
   sw x16, 60(t0)
   sw x17, 64(t0)
   sw x18, 68(t0)
   sw x19, 72(t0)
   sw x20, 76(t0)
   sw x21, 80(t0)
   sw x22, 84(t0)
   sw x23, 88(t0)
   sw x24, 92(t0)
   sw x25, 96(t0)
   sw x26, 100(t0)
   sw x27, 104(t0)
   sw x28, 108(t0)
   sw x29, 112(t0)
   sw x30, 116(t0)
   sw x31, 120(t0)

   # lw t1, -16(sp) // original t0
   csrrw t1, mscratch, x0
   sw t1, 16(t0)
   csrr t1, mepc
   sw t1, 124(t0)

   # : set up new timer interrupt + implement process switch
   la s0, mtimecmp
   lw a0, 0(s0)
   lw a1, 4(s0)
   li a2, 300
   jal ra, add_64_bit
   li t0, -1
   sw t0, 0(s0)
   sw a1, 4(s0)
   sw a0, 0(s0)

   li t0, 0x0 // PROCESS_ID_ADDRESS
   lw a0, 0(t0)
   jal ra, get_next_process_id

   li t0, 0x0 // PROCESS_ID_ADDRESS
   sw a0, 0(t0) // a0 = next process id

   // make a0 equal to address of pcb
   // pcb address = PCB_ADDRESS + a0 * PCB_SIZE
   slli a0, a0, 7 // PCB_SIZE
   addi a0, a0, 0x10 // PCB_ADDRESS


   lw t0, 124(a0)
   csrw mepc, t0

   lw x1, 0(a0)
   lw x2, 4(a0)
   lw x3, 8(a0)
   lw x4, 12(a0)
   lw x5, 16(a0)
   lw x6, 20(a0)
   lw x7, 24(a0)
   lw x8, 28(a0)
   lw x9, 32(a0)
   # lw x10, 36(a0) // x10 is a0 do it at the end
   lw x11, 40(a0)
   lw x12, 44(a0)
   lw x13, 48(a0)
   lw x14, 52(a0)
   lw x15, 56(a0)
   lw x16, 60(a0)
   lw x17, 64(a0)
   lw x18, 68(a0)
   lw x19, 72(a0)
   lw x20, 76(a0)
   lw x21, 80(a0)
   lw x22, 84(a0)
   lw x23, 88(a0)
   lw x24, 92(a0)
   lw x25, 96(a0)
   lw x26, 100(a0)
   lw x27, 104(a0)
   lw x28, 108(a0)
   lw x29, 112(a0)
   lw x30, 116(a0)
   lw x31, 120(a0)
   lw x10, 36(a0)

   # : return to user mode to continue with next process
   mret

   // addi sp, sp, 16

// only add positive numbers
// a0 first half
// a1 upper half
// a2 add what
// return value in a0 and a1
add_64_bit:
   mv t0, a0
   add a0, a0, a2
   sltu t1, a0, t0
   add a1, a1, t1
   ret

// a0 = current process id
// a0 return value
get_next_process_id:
   # if (a0 == 0) {
   #    return 1;
   # } else {
   #    return 0;
   # }

   beq a0, x0, get_next_process_id_return_one
   j get_next_process_id_return_zero

   get_next_process_id_return_one:
   li a0, 1
   ret

   get_next_process_id_return_zero:
   li a0, 0
   ret


