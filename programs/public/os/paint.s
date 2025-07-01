paint_start:
   # addi   sp, sp, -128
	sw     ra,  60(x0)
	sw     t0,  56(x0)
	sw     t1,  52(x0)
	sw     t2,  48(x0)
	sw     t3,  44(x0)
	sw     t4,  40(x0)
	sw     t5,  36(x0)
	sw     t6,  32(x0)
   sw     s2,  28(x0)
   sw     s3,  24(x0)
   sw     s4,  20(x0)
   sw     s5,  16(x0)
   sw     s6,  12(x0)
   sw     s7,  8(x0)
   sw     s8,  4(x0)
   sw     s9,  0(x0)
   sw     a0,  64(x0)
   sw     a1,  68(x0)
   sw     a2,  72(x0)
   sw     a3,  76(x0)
   sw     a4,  80(x0)
   sw     a5,  84(x0)
   sw     a6,  88(x0)
   sw     a7,  92(x0)
   sw     sp, 96(x0)

   li sp, 0xffff

   // (0, 0) top left
   // s0 = cursor x
   // s1 = cursor y
   // s2 = cursor color

   li t0, 15
   mv s0, t0
   mv s1, t0

   li t0, 0x00ffffff // white
   mv s2, t0

   paint_start_loop_begin:
# : wait for keyboard input
# : read keyboard input
   jal ra, read_keyboard_input
   mv s3, a0  # s3 = keyboard input

# : update cursor and display accordingly

   # if (s3 == 'w') {
   #    move up
   # } else if (s3 == 's') {
   #    move down
   # } else if (s3 == 'a') {
   #    move left
   # } else if (s3 == 'd') {
   #    move right
   # } else if (s3 == ' ') {
   #    set pixel to current color
   # } else if (s3 == 'r') {
   #    flip red
   # } else if (s3 == 'g') {
   #    flip green
   # } else if (s3 == 'b') {
   #    flip blue
   # }

   li t0, 119 // w
   beq s3, t0, paint_start_if_w
   li t0, 115 // s
   beq s3, t0, paint_start_if_s
   li t0, 97  // a
   beq s3, t0, paint_start_if_a
   li t0, 100 // d
   beq s3, t0, paint_start_if_d
   li t0, 32  // space
   beq s3, t0, paint_start_if_space
   li t0, 114 // r
   beq s3, t0, paint_start_if_r
   li t0, 103 // g
   beq s3, t0, paint_start_if_g
   li t0, 98 // b
   beq s3, t0, paint_start_if_b

   // invalid keyboard input. ignore it
   j paint_start_if_end

   paint_start_if_begin:
   paint_start_if_w:
   addi s1, s1, -1
   mv a0, s1
   jal ra, clamp_0_31
   mv s1, a0
   j paint_start_if_end
   paint_start_if_s:
   addi s1, s1, 1
   mv a0, s1
   jal ra, clamp_0_31
   mv s1, a0
   j paint_start_if_end
   paint_start_if_a:
   addi s0, s0, -1
   mv a0, s0
   jal ra, clamp_0_31
   mv s0, a0
   j paint_start_if_end
   paint_start_if_d:
   addi s0, s0, 1
   mv a0, s0
   jal ra, clamp_0_31
   mv s0, a0
   j paint_start_if_end
   paint_start_if_space:
   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display
   j paint_start_if_end
   paint_start_if_r:
   li t0, 0x00ff0000
   xor s2, s2, t0
   j paint_start_if_end
   paint_start_if_g:
   li t0, 0x0000ff00
   xor s2, s2, t0
   j paint_start_if_end
   paint_start_if_b:
   li t0, 0x000000ff
   xor s2, s2, t0
   j paint_start_if_end
   paint_start_if_end:


# : wait for next keyboard input
   j paint_start_loop_begin
   paint_start_loop_end:

	lw       ra,  60(x0)
	lw       t0,  56(x0)
	lw       t1,  52(x0)
	lw       t2,  48(x0)
	lw       t3,  44(x0)
	lw       t4,  40(x0)
	lw       t5,  36(x0)
	lw       t6,  32(x0)
   lw       s2,  28(x0)
   lw       s3,  24(x0)
   lw       s4,  20(x0)
   lw       s5,  16(x0)
   lw       s6,  12(x0)
   lw       s7,  8(x0)
   lw       s8,  4(x0)
   lw       s9,  0(x0)
   lw       a0,  64(x0)
   lw       a1,  68(x0)
   lw       a2,  72(x0)
   lw       a3,  76(x0)
   lw       a4,  80(x0)
   lw       a5,  84(x0)
   lw       a6,  88(x0)
   lw       a7,  92(x0)
   lw       sp, 96(x0)
	# addi    sp,  sp,  128
   ret // ? idk


# wait_until_terminal_is_ready:
#    la t0, terminal_ready

#    wait_until_terminal_is_ready_loop:
#    lbu t1, 0(t0)
#    beq t1, x0, wait_until_terminal_is_ready_loop

#    ret

// when keyboard is ready then it means there is interrupt
wait_for_keyboard_interrupt:
   la t0, keyboard_ready

   wait_for_keyboard_interrupt_loop:
   lbu t1, 0(t0)
   beq t1, x0, wait_for_keyboard_interrupt_loop

   ret

// waits for keyboard to be ready
// a0 return value
read_keyboard_input:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   jal ra, wait_for_keyboard_interrupt
   la t0, keyboard_data
   lbu a0, 0(t0)

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret

// a0 input and return value
clamp_0_31:
   # if (a0 < 0) {
   #    a0 = 0
   # } else if (a0 > 31) {
   #    a0 = 31
   # }

   blt a0, x0, clamp_0_31_if
   li t0, 31
   bgt a0, t0, clamp_0_31_else_if

   // if neither is the case then a0 is already in range
   j clamp_0_31_if_end

   clamp_0_31_if:
   li a0, 0
   j clamp_0_31_if_end
   clamp_0_31_else_if:
   li a0, 31
   j clamp_0_31_if_end
   clamp_0_31_if_end:

   ret

// a0 = x
// a1 = y
// a0 return value
read_display:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   jal ra, x_y_to_display_memory
   lw a0, 0(a0)

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret

// a0 = x
// a1 = y
// a2 = color
write_display:
   addi sp, sp, -16
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)

   mv s0, a2

   jal ra, x_y_to_display_memory
   sw s0, 0(a0)

   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   addi sp, sp, 16
   ret

// a0 = x
// a1 = y
// a0 return value
x_y_to_display_memory:
   // display + 4 · x + 32 · 4 · y
   la t0, display
   slli a1, a1, 7  // 32 * 4 * y
   slli a0, a0, 2  // 4 * x
   add a0, a0, a1  // 4 * x + 32 * 4 * y
   add a0, a0, t0  // plus display

   ret

