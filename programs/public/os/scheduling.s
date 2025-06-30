// i know these are comments. i couldnt find a way to have macros. .equ doesnt work so i hard code them in the code
// this comments are just for the refernce
#define PCB_ADDRESS 0x0 // this time zero
#define PCB_SIZE (124 + 4 + 4 + 4) // 124 registers + 4 pc + 4 remaining cycles + 4 occupied (4 for occupied notone because aligmnet idk)
#define MAX_PROCESS_COUNT 8
#define PROCESS_ID_ADDRESS (MAX_PROCESS_COUNT * PCB_SIZE + PCB_ADDRESS) // at the end of pcb array.
                                                                        // process id is 4 bytes
# #define OCCUPIED_ARRAY_ADDRESS (PROCESS_ID_ADDRESS + 4) // at the end of process id
#                                                         // one byte per process
#                                                         // either 0 or 1
#                                                         // so the size of the array is MAX_PROCESS_COUNT
# #define REMAINING_CYCLES_ARRAY_ADDRESS (OCCUPIED_ARRAY_ADDRESS + MAX_PROCESS_COUNT) // at the end of occupied array
#                                                                                     // 4 bytes per process
#                                                                                     // so the size of the array is MAX_PROCESS_COUNT * 4
#define TEMP_T0_T1_ADDRESS (PROCESS_ID_ADDRESS + 4) // at the end of process id address
#define LAST_INTERRUPT_TIMESTAMP_ADDRESS (TEMP_T0_T1_ADDRESS + 4) // at the end of temp t0 t1 address
                                                                  // 8 bytes.
                                                                  // this just copies the mtime

# : set up exception handler
la t0, exception_handler        # setting up exception handler
csrw mtvec, t0                  # ...

# : set up mepc to point to the first instruction of the startup function
la t0, startup
csrw mepc, t0

# TODO: enable and set up interrupts as needed
# : set up data structures for process control blocks
li t0, 1088 // PROCESS_ID_ADDRESS
sw x0, 0(t0) // current process id is 0 which is startup

la t0, mtime
sw x0, 0(t0)
sw x0, 4(t0)

// pcbs[0].isOccupied = 1
li t0, 1
li t1, 132 // PCB_SIZE - 4. location of occupied.
sw t0, 0(t1)

// pcbs[0].remainingCycles = MIN_VALUE
li t0, 1
slli t0, t0, 31
li t1, 128 // PCB_SIZE - 8. location of remaining cycles.
sw t0, 0(t1)

# : execute the startup process until you get a system call
mret

// TODO(apila, 30/06/25): my remaining cycle calculator is wrong. idk why. maybe it is idk mtime maybe last interrupt timestamp
//    or maybe the calculator. idk. it just doesnt work. unlucky i guess
//    but most likely my last interrupt timestamp is wrong. i have to make sure that i store the correct value there
//    anyways thats it from me today. if you step 10010 times you you get to close to mret. and that mret should return to a dummy_job not jobB
//    at that point jobB is only executed once and made an ecall. after jobB makes an ecall it should mret to a dummy_job but somehow i calculate the priority of
//    jobB to be negative (at first it was 200) but it should be somewhere 150-200.
exception_handler:
   # : save some registers
   csrrw x0, mscratch, t0

   // t0 is not saved it is in mscracth
   li t0, 1092 // TEMP_T0_T1_ADDRESS
   sw t1, 4(t0)

   li t0, 1088 // PROCESS_ID_ADDRESS
   lw t0, 0(t0)
   // pcb address = PCB_ADDRESS + PROCESS_ID * PCB_SIZE
   li t1, 136 // PCB_SIZE
   mul t0, t0, t1
   # addi t0, t0, 0x0 // PCB_ADDRESS

   sw x1, 0(t0)
   sw x2, 4(t0)
   sw x3, 8(t0)
   sw x4, 12(t0)
   sw x5, 16(t0) // t0 needs be resaved
   sw x6, 20(t0) // t1 also needs to be resaved
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

   li t1, 1092 // TEMP_T0_T1_ADDRESS
   lw t1, 4(t1) // originla t1
   sw t1, 20(t0)

   csrrw t1, mscratch, x0
   sw t1, 16(t0)
   csrr t1, mepc
   sw t1, 124(t0)

   li sp, 0xffff // so i can use the stack to store some data in the functions

   // s1 = mtime at the start of exception_handler (lower)
   // s2 = mtime at the start of exception_handler (upper)
   // s1, s2 = mtime - (&exception_handler_here - &exception_handler)

   la t0, mtime
   # la t1, exception_handler
   # la t2, exception_handler_here

   # sub a2, t2, t1
   # exception_handler_here:
   # lw a0, 0(t0)
   # lw a1, 4(t0)
   # jal ra, subtract_64_bit

   # mv s1, a0
   # mv s2, a1

   lw s1, 0(t0)
   addi s1, s1, -48

   # : identify cause of exception (ecall? which one?)

   // s0 = the process id to mret to. even in early returns

   # if (!ecall) {
   #    return;
   # }

   # if (exec) {
   #    do exec stuff
   # } else if(exit) {
   #    do exit stuff
   # }

   li t0, 1088 // PROCESS_ID_ADDRESS
   lw s0, 0(t0) // in case of early return return to the process

   // s3 = return value. (for exec)
   // otherwise it shouldnt change. so by default it should be equal to a0
   # mv a0, s0
   # jal ra, get_pcb_address_from_process_id
   # lw s3, 36(a0)

   csrr t0, mcause
   srli t1, t0, 31
   bne t1, x0, exception_handler_return // if mcause[31] == 1 then its an interrupt and i ignore it
   li t1, 8
   bne t0, t1, exception_handler_return // if mcause != 8 then its not a system call and i ignore it

   mv a0, s0
   jal ra, get_pcb_address_from_process_id
   lw a7, 64(a0)

   li t0, 221
   beq a7, t0, exception_handler_if_exec
   li t0, 93
   beq a7, t0, exception_handler_if_exit
   j exception_handler_if_end

   exception_handler_if_exec:
   lw a1, 40(a0)
   lw a0, 36(a0)
   jal ra, do_exec

   # if (return value == -1) {
   #    a0 = -1
   #    do mret
   # }

   li t0, -1
   beq a0, t0, exception_handler_if_exec_if_minus_one
   j exception_handler_if_exec_if_minus_one_end

   exception_handler_if_exec_if_minus_one:
   // s0 already has the process id to mret to
   li a0, -1
   mv a1, s0
   jal ra, write_to_pcb_a0
   j exception_handler_return
   exception_handler_if_exec_if_minus_one_end:

   # update_current_process_remaning_cycles();
   # pid = get_process_id_stcf();
   # set s0 to pid
   # do mret

   li t0, 1096 // LAST_INTERRUPT_TIMESTAMP_ADDRESS
   lw t1, 0(t0)

   sub a1, s1, t1
   mv a0, s0
   jal ra, update_current_process_remaning_cycles

   jal ra, get_process_id_stcf
   mv s0, a0
   j exception_handler_return

   j exception_handler_if_end
   exception_handler_if_exit:
   # pcbs[current_process_id].isOccupied = 0;
   # int alive_processes = get_alive_processes_count();
   # if (alive_processes == 0) {
   #    set mepc to address of shutdown label
   #    return;
   # }

   # pid = get_process_id_stcf();
   # set s0 to pid
   # do mret

   mv a0, s0
   jal ra, get_pcb_address_from_process_id

   sw x0, 132(a0)

   jal ra, get_alive_processes_count

   beq a0, x0, exception_handler_if_exit_if_no_alive_processes
   j exception_handler_if_exit_if_no_alive_processes_end

   exception_handler_if_exit_if_no_alive_processes:
      jal ra, shutdown
      # la t0, shutdown
      # csrw mepc, t0
      # mret
   exception_handler_if_exit_if_no_alive_processes_end:

   jal ra, get_process_id_stcf
   mv s0, a0
   j exception_handler_return

   j exception_handler_if_end
   exception_handler_if_end:

   # : update time to completion for the process that caused the exception

   # : schedule next process
   // at this point i assume s0 has the process id to mret to
   exception_handler_return:
   li t0, 1088 // PROCESS_ID_ADDRESS
   sw s0, 0(t0)

   la t0, mtime
exception_handler_here_2:
   lw t1, 0(t0)
   # lw t2, 4(t0)

   // last interrupt = mtime + (&exception_handler_mret - &exception_handler_here_2) + add_64_bit cycles

   # mv a0, t1
   # mv a1, t2
   # la a2, exception_handler_mret
   # la t0, exception_handler_here_2
   # sub a2, a2, t0
   # addi a2, a2, 5 // 5 for add_64_bit
   # jal ra, add_64_bit

   # li t0, 1096 // LAST_INTERRUPT_TIMESTAMP_ADDRESS
   # sw a0, 0(t0)
   # sw a1, 4(t0)

   # la a2, exception_handler_mret
   # la t0, exception_handler_here_2
   # sub a2, a2, t0

   addi a0, t1, 40
   li t0, 1096 // LAST_INTERRUPT_TIMESTAMP_ADDRESS
   sw a0, 0(t0)


   mv a0, s0
   jal ra, get_pcb_address_from_process_id

   // mepc = pcbs[process_id].pc + 4
   lw t0, 124(a0)
   addi t0, t0, 4
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
   # mv x10, s3 // s3 is return value

exception_handler_mret:
   mret

// a0 what to write (a0 return value)
// a1 process id
write_to_pcb_a0:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   mv s0, a0
   mv s1, a1

   mv a0, s1
   jal ra, get_pcb_address_from_process_id

   sw s0, 36(a0)

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret


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

// a0 = process id
// a0 return value
get_pcb_address_from_process_id:
   // return PCB_SIZE * a0 + PCB_ADDRESS
   li t0, 136 // PCB_SIZE
   mul a0, a0, t0
   addi a0, a0, 0x0 // PCB_ADDRESS
   ret

// a0 = pc
// a1 = estimated time to completion
// a0 return value. if -1 then no more processes can be added
do_exec:
   addi sp, sp, -32
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   sw s5, 24(sp)
   sw s6, 28(sp)

   mv s0, a0 // pc
   mv s1, a1 // estimated time to completion

   jal ra, get_unused_process_id

   # if (a0 == -1) {
   #    return -1;
   # }

   li t0, -1
   beq a0, t0, do_exec_if_all_occupied
   j do_exec_if_all_occupied_end

   do_exec_if_all_occupied:
   li a0, -1
   j do_exec_return
   do_exec_if_all_occupied_end:

   // pcbs[new_process_id].registers = pcbs[current_process_id].registers

   // s2 = new_process_id pcb address
   jal ra, get_pcb_address_from_process_id
   mv s2, a0

   // s3 = current_process_id pcb address
   li t0, 1088 // PROCESS_ID_ADDRESS
   lw a0, 0(t0)
   jal ra, get_pcb_address_from_process_id
   mv s3, a0

   lw t0, 0(s3)
   sw t0, 0(s2) // x1
   lw t0, 4(s3)
   sw t0, 4(s2) // x2
   lw t0, 8(s3)
   sw t0, 8(s2) // x3
   lw t0, 12(s3)
   sw t0, 12(s2) // x4
   lw t0, 16(s3)
   sw t0, 16(s2) // x5
   lw t0, 20(s3)
   sw t0, 20(s2) // x6
   lw t0, 24(s3)
   sw t0, 24(s2) // x7
   lw t0, 28(s3)
   sw t0, 28(s2) // x8
   lw t0, 32(s3)
   sw t0, 32(s2) // x9
   lw t0, 36(s3)
   sw t0, 36(s2) // x10
   lw t0, 40(s3)
   sw t0, 40(s2) // x11
   lw t0, 44(s3)
   sw t0, 44(s2) // x12
   lw t0, 48(s3)
   sw t0, 48(s2) // x13
   lw t0, 52(s3)
   sw t0, 52(s2) // x14
   lw t0, 56(s3)
   sw t0, 56(s2) // x15
   lw t0, 60(s3)
   sw t0, 60(s2) // x16
   lw t0, 64(s3)
   sw t0, 64(s2) // x17
   lw t0, 68(s3)
   sw t0, 68(s2) // x18
   lw t0, 72(s3)
   sw t0, 72(s2) // x19
   lw t0, 76(s3)
   sw t0, 76(s2) // x20
   lw t0, 80(s3)
   sw t0, 80(s2) // x21
   lw t0, 84(s3)
   sw t0, 84(s2) // x22
   lw t0, 88(s3)
   sw t0, 88(s2) // x23
   lw t0, 92(s3)
   sw t0, 92(s2) // x24
   lw t0, 96(s3)
   sw t0, 96(s2) // x25
   lw t0, 100(s3)
   sw t0, 100(s2) // x26
   lw t0, 104(s3)
   sw t0, 104(s2) // x27
   lw t0, 108(s3)
   sw t0, 108(s2) // x28
   lw t0, 112(s3)
   sw t0, 112(s2) // x29
   lw t0, 116(s3)
   sw t0, 116(s2) // x30
   lw t0, 120(s3)
   sw t0, 120(s2) // x31

   // pcbs[new_process_id].isOccupied = 1
   li t0, 1
   sw t0, 132(s2)

   // pcbs[new_process_id].remainingCycles = estimated time to completion
   sw s1, 128(s2)

   // pcbs[new_process_id].pc = pc - 4
   // -4 because i always add +4. so this is a hack but it works and idc
   addi t0, s0, -4
   sw t0, 124(s2)

   mv a0, x0 // so that is it not -1

   do_exec_return:
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   lw s5, 24(sp)
   lw s6, 28(sp)
   addi sp, sp, 32
   ret

// a0 return value. -1 if all occupied
get_unused_process_id:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   # for (int i = 0; i < MAX_PROCESS_COUNT; i++) {
   #    if (!pcbs[i].isOccupied) {
   #       return i;
   #    }
   # }

   # return -1;

   // s0 = i
   li s0, 0
   j get_unused_process_id_for_loop_condition

   get_unused_process_id_for_loop_begin:
   mv a0, s0
   jal ra, get_pcb_address_from_process_id
   lw t0, 132(a0)

   beq t0, x0, get_unused_process_id_for_loop_if_not_occupied
   j get_unused_process_id_for_loop_if_not_occupied_end

   get_unused_process_id_for_loop_if_not_occupied:
      mv a0, s0
      j get_unused_process_id_return
   get_unused_process_id_for_loop_if_not_occupied_end:

   # mv a0, s0 // in case of return
   # beq t0, x0, get_unused_process_id_return

   // i++
   addi s0, s0, 1
   get_unused_process_id_for_loop_condition:
   li t0, 8 // MAX_PROCESS_COUNT
   blt s0, t0, get_unused_process_id_for_loop_begin

   li a0, -1

   get_unused_process_id_return:
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret

// a0 return value
get_process_id_stcf:
   # int min_remaining_cycles = INT_MAX;
   # int min_process_id = -1;
   # for (int i = 0; i < MAX_PROCESS_COUNT; i++) {
   #    if (pcbs[i].isOccupied) {
   #       if (pcbs[i].remaining_cycles < min_remaining_cycles) {
   #          min_remaining_cycles = pcbs[i].remaining_cycles;
   #          min_process_id = i;
   #       }
   #    }
   # }

   # return min_process_id;

   addi sp, sp, -32
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   sw s5, 24(sp)
   sw s6, 28(sp)

   // s0 = min_remaining_cycles
   // s1 = min_process_id
   // s2 = i

   li s0, 2147483647 // INT_MAX
   li s1, -1
   li s2, 0

   j get_process_id_stcf_for_loop_condition

   get_process_id_stcf_for_loop_begin:
   mv a0, s2
   jal ra, get_pcb_address_from_process_id
   lw t0, 132(a0) // isOccupied

   bne t0, x0, get_process_id_stcf_for_loop_if_occupied
   j get_process_id_stcf_for_loop_if_occupied_end

   get_process_id_stcf_for_loop_if_occupied:
      lw t0, 128(a0) // remaining_cycles
      blt t0, s0, get_process_id_stcf_for_loop_if_less_than_min
      j get_process_id_stcf_for_loop_if_less_than_min_end

      get_process_id_stcf_for_loop_if_less_than_min:
         mv s0, t0
         mv s1, s2
      get_process_id_stcf_for_loop_if_less_than_min_end:

   get_process_id_stcf_for_loop_if_occupied_end:

   addi s2, s2, 1 // i++
   get_process_id_stcf_for_loop_condition:
   li t0, 8 // MAX_PROCESS_COUNT
   blt s2, t0, get_process_id_stcf_for_loop_begin

   mv a0, s1

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   lw s5, 24(sp)
   lw s6, 28(sp)
   addi sp, sp, 32
   ret


// only operate on lower halfs
// sub a0, a0, t1
# // a0 = mtime at start (lower)
# // a1 = mtime at start (upper)
# // a0 return value
# get_executed_cycles:
#    li t0, 1096 // LAST_INTERRUPT_TIMESTAMP_ADDRESS
#    lw t1, 0(t0)
#    lw t2 0(t0)


// a0 = process id
// a1 = time it executed
update_current_process_remaning_cycles:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   mv s0, a0
   mv s1, a1

   jal ra, get_pcb_address_from_process_id

   lw t0, 128(a0)
   sub t0, t0, s1
   sw t0, 128(a0)

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret

// a0 return value
get_alive_processes_count:
   # int result = 0;
   # for (int i = 0; i < MAX_PROCESS_COUNT; i++) {
   #    if (pcbs[i].isOccupied) {
   #       result++;
   #    }
   # }

   # return result;

   addi sp, sp, -32
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   sw s5, 24(sp)
   sw s6, 28(sp)

   // s0 = result
   // s1 = i

   li s0, 0
   li s1, 0
   j get_alive_processes_count_for_loop_condition

   get_alive_processes_count_for_loop_begin:
   mv a0, s1
   jal ra, get_pcb_address_from_process_id

   lw t0, 132(a0)

   bne t0, x0, get_alive_processes_count_for_loop_if_occupied
   j get_alive_processes_count_for_loop_if_occupied_end

   get_alive_processes_count_for_loop_if_occupied:
      addi s0, s0, 1
   get_alive_processes_count_for_loop_if_occupied_end:

   addi s1, s1, 1 // i++
   get_alive_processes_count_for_loop_condition:
   li t0, 8 // MAX_PROCESS_COUNT
   blt s1, t0, get_alive_processes_count_for_loop_begin

   mv a0, s0

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   lw s5, 24(sp)
   lw s6, 28(sp)
   addi sp, sp, 32
   ret


// a0 = 64bit lower half
// a1 = 64 bit upper half
// a2 = subtract value
// a0 return value
// a1 return value
subtract_64_bit:
   mv    t0, a0          # t0 = old low half
   sub   a0, a0, a2      # a0 = low_half - amount
   sltu  t1, a0, t0      # t1 = 1 if a0 < old_low (i.e. borrow), else 0
   sub   a1, a1, t1      # a1 = high_half - borrow
   ret

shutdown:
