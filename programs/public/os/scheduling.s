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

   # TODO: identify cause of exception (ecall? which one?)
   # TODO: update time to completion for the process that caused the exception
   # TODO: schedule next process