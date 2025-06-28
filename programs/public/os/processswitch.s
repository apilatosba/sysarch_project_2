.equ PCB_ADDRESS, 0x0010 // not zero because otherwise idk it looks like a null pointer
.equ PCB_SIZE, 128 // just enough for 32 registers

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

li t0, 1088 // 11th and 7th bits are on
csrr t1, mie
or t1, t1, t0
csrw mie, t1

# li t0, 4 // 0b100
# csrr t1, mstatus
# or t1, t1, t0
# csrw mstatus, t1

# TODO: set up data structures for process control blocks

# : execute the fibonacci function until you get an interrupt
mret


exception_handler:
   # TODO: save some registers
   # TODO: set up new timer interrupt + implement process switch
   # TODO: return to user mode to continue with next process

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
