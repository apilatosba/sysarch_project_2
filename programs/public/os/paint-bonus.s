#                                                                                                                                                 @
#                                                                                                                                                 @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .................................................................       ..       ............................................................. @
#  ................................................................. @@@@@  . @@@@% ............................................................. @
#  .........................................................      .. @@@@@    @@@@@ ...      .................................................... @
#  ........................................................       ..                ..        ................................................... @
#  ........................................................ @@@@@ ....... @@@@@ ...... @@@@@  ................................................... @
#  ........................................................ @@@@@     ...       .      @@@@@  ................................................... @
#  ........................................................      @@@@             @@@@@@      ................................................... @
#  .........................................................     @@@@@@@@@@@@@@@@@@@@@@%     .................................................... @
#  ............................................................      @@@@@@@@@@@@@@      ........................................................ @
#  .................................................................                ............................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#  .............................................................................................................................................. @
#                                                                                                                                                 @

# this is what i see when i press 1

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
   // s4 = state (read_from_1 or normal)
   // s5 = read_from_1 pointer. points to the current character in the read_from_1 buffer
   // s6 = current underlying pixel color

   li t0, 15
   mv s0, t0
   mv s1, t0

   li t0, 0x00ffffff // white
   mv s2, t0

   // need to write the cursor color at start
   # s6 = read_display(cursor_position);
   # write_display(cursor_color, cursor_position);

   mv a0, s0
   mv a1, s1
   jal ra, read_display
   mv s6, a0

   mv a0, s0,
   mv a1, s1
   mv a2, s2
   jal ra, write_display

   mv s4, x0 // (0 = normal, 1 = read_from_1)
   mv s5, x0 // not important. will be initilaized if "1" is pressed

   paint_start_loop_begin:
# : wait for keyboard input
# : read keyboard input
   beq s4, x0, paint_start_if_state_normal
   li t0, 1
   beq s4, t0, paint_start_if_state_read_from_1

   // should be unreachble

   paint_start_if_state_normal:
   jal ra, read_keyboard_input
   mv s3, a0  # s3 = keyboard input
   j paint_start_if_state_end
   paint_start_if_state_read_from_1:
   lbu t0, 0(s5)
   beq t0, x0, paint_start_if_state_read_from_1_if_null_terminator
   j paint_start_if_state_read_from_1_if_null_terminator_end
      paint_start_if_state_read_from_1_if_null_terminator:
      mv s4, x0
      j paint_start_loop_begin
      paint_start_if_state_read_from_1_if_null_terminator_end:
   mv s3, t0
   addi s5, s5, 1
   j paint_start_if_state_end
   paint_start_if_state_end:


# : update cursor and display accordingly

   # if (state == normal) {
   #    s3 == keyboard input
   # } else if(state == read_from_1) {
   #    if (*s5 == 0) {
   #       set s4 to normal
   #       continue;
   #    }
   #    s3 = *s5
   #    s5++;
   # }

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
   # } else if(s3 == 'p') {
   #    set color to current pixel
   # } else if(s3 == 'm') {
   #    cursor color = (current pixel + cursor color) / 2
   # } else if(s3 == '1') {
   #    change state to read_from_1
   #    set s5 to 0x00010000
   # }

   // on wasd i need to this:
   # write_display(cursor_position, s6);
   # update cursor position
   # s6 = read_display(cursor_position);
   # write_display(cursor_position, s2);


   // for input 1 maybe use a state and if state is read_from_1 then read from 0x00010000
   // and when you hit a null terminator switch state baack to normal

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
   li t0, 112 // p
   beq s3, t0, paint_start_if_p
   li t0, 109 // m
   beq s3, t0, paint_start_if_m
   li t0, 49 // 1
   beq s3, t0, paint_start_if_1

   // invalid keyboard input. ignore it
   j paint_start_if_end

   paint_start_if_begin:
   paint_start_if_w:
   mv a0, s0
   mv a1, s1
   mv a2, s6
   jal ra, write_display

   addi s1, s1, -1
   mv a0, s1
   jal ra, clamp_0_31
   mv s1, a0

   mv a0, s0
   mv a1, s1
   jal ra, read_display
   mv s6, a0

   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display
   j paint_start_if_end
   paint_start_if_s:
   mv a0, s0
   mv a1, s1
   mv a2, s6
   jal ra, write_display

   addi s1, s1, 1
   mv a0, s1
   jal ra, clamp_0_31
   mv s1, a0

   mv a0, s0
   mv a1, s1
   jal ra, read_display
   mv s6, a0

   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display
   j paint_start_if_end
   paint_start_if_a:
   mv a0, s0
   mv a1, s1
   mv a2, s6
   jal ra, write_display

   addi s0, s0, -1
   mv a0, s0
   jal ra, clamp_0_31
   mv s0, a0

   mv a0, s0
   mv a1, s1
   jal ra, read_display
   mv s6, a0

   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display
   j paint_start_if_end
   paint_start_if_d:
   mv a0, s0
   mv a1, s1
   mv a2, s6
   jal ra, write_display

   addi s0, s0, 1
   mv a0, s0
   jal ra, clamp_0_31
   mv s0, a0

   mv a0, s0
   mv a1, s1
   jal ra, read_display
   mv s6, a0

   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display
   j paint_start_if_end
   paint_start_if_space:
   mv s6, s2
   # mv a0, s0
   # mv a1, s1
   # mv a2, s2
   # jal ra, write_display
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
   paint_start_if_p:
   mv s2, s6
   # mv a0, s0
   # mv a1, s1
   # jal ra, read_display
   # mv s2, a0
   j paint_start_if_end
   paint_start_if_m:
   # mv a0, s0
   # mv a1, s1
   # jal ra, read_display
   # // a0 = current pixel
   // s6 is now underlying pixel color
   // s2 = current color
   // t4 = new blue
   // t5 = new green
   // t6 = new red

   // a5 = blue mask
   // a6 = green mask
   // a7 = red mask

   // because of stupid 12 bit immediate thingy. i cant do andi 0xff00
   li a5, 0xff
   slli a6, a5, 8
   slli a7, a5, 16

   and t0, s6, a5
   and t1, s2, a5
   add t0, t0, t1
   srli t4, t0, 1

   and t0, s6, a6
   and t1, s2, a6
   srli t0, t0, 8
   srli t1, t1, 8
   add t0, t0, t1
   srli t0, t0, 1
   slli t5, t0, 8

   and t0, s6, a7
   and t1, s2, a7
   srli t0, t0, 16
   srli t1, t1, 16
   add t0, t0, t1
   srli t0, t0, 1
   slli t6, t0, 16

   or t6, t6, t5
   or t6, t6, t4
   mv s2, t6

   j paint_start_if_end
   paint_start_if_1:
   li s4, 1
   li s5, 0x00010000
   j paint_start_if_end
   paint_start_if_end:

   # if(cursor color changed) {
   #    write_display(cursor_position, cursor_color);
   # }

   // i dont do the if check
   mv a0, s0
   mv a1, s1
   mv a2, s2
   jal ra, write_display

# : wait for next keyboard input
   j paint_start_loop_begin
   paint_start_loop_end:

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

