
// We keep track of any non-zero characters on the screen. Each row has
// at most 40 characters, so we allocate 40 per row. However in practice
// most rows will be empty or only have a handful of characters.
// 
// Any time the screen scrolls by a character, this table will get updated.
//
// It's implemented as a ring buffer with a start index and end index pointer.
//   The data between these indices are locations in this row where
//   there is a non-zero character on the screen.
//   Note: an empty buffer will have equal start and end index.
row_0_chars_start_idx:  .byte 0
row_0_chars_end_idx:    .byte 0
row_0_chars_buffer:     .fill 40,0
row_1_chars_start_idx:  .byte 0
row_1_chars_end_idx:    .byte 0
row_1_chars_buffer:     .fill 40,0
row_2_chars_start_idx:  .byte 0
row_2_chars_end_idx:    .byte 0
row_2_chars_buffer:     .fill 40,0
row_3_chars_start_idx:  .byte 0
row_3_chars_end_idx:    .byte 0
row_3_chars_buffer:     .fill 40,0
row_4_chars_start_idx:  .byte 0
row_4_chars_end_idx:    .byte 0
row_4_chars_buffer:     .fill 40,0
row_5_chars_start_idx:  .byte 0
row_5_chars_end_idx:    .byte 0
row_5_chars_buffer:     .fill 40,0
row_6_chars_start_idx:  .byte 0
row_6_chars_end_idx:    .byte 0
row_6_chars_buffer:     .fill 40,0
row_7_chars_start_idx:  .byte 0
row_7_chars_end_idx:    .byte 0
row_7_chars_buffer:     .fill 40,0
row_8_chars_start_idx:  .byte 0
row_8_chars_end_idx:    .byte 0
row_8_chars_buffer:     .fill 40,0
row_9_chars_start_idx:  .byte 0
row_9_chars_end_idx:    .byte 0
row_9_chars_buffer:     .fill 40,0
row_10_chars_start_idx: .byte 0
row_10_chars_end_idx:   .byte 0
row_10_chars_buffer:    .fill 40,0
row_11_chars_start_idx: .byte 0
row_11_chars_end_idx:   .byte 0
row_11_chars_buffer:    .fill 40,0
row_12_chars_start_idx: .byte 0
row_12_chars_end_idx:   .byte 0
row_12_chars_buffer:    .fill 40,0
row_13_chars_start_idx: .byte 0
row_13_chars_end_idx:   .byte 0
row_13_chars_buffer:    .fill 40,0
row_14_chars_start_idx: .byte 0
row_14_chars_end_idx:   .byte 0
row_14_chars_buffer:    .fill 40,0
row_15_chars_start_idx: .byte 0
row_15_chars_end_idx:   .byte 0
row_15_chars_buffer:    .fill 40,0
row_16_chars_start_idx: .byte 0
row_16_chars_end_idx:   .byte 0
row_16_chars_buffer:    .fill 40,0
row_17_chars_start_idx: .byte 0
row_17_chars_end_idx:   .byte 0
row_17_chars_buffer:    .fill 40,0
row_18_chars_start_idx: .byte 0
row_18_chars_end_idx:   .byte 0
row_18_chars_buffer:    .fill 40,0
row_19_chars_start_idx: .byte 0
row_19_chars_end_idx:   .byte 0
row_19_chars_buffer:    .fill 40,0
row_20_chars_start_idx: .byte 0
row_20_chars_end_idx:   .byte 0
row_20_chars_buffer:    .fill 40,0
row_21_chars_start_idx: .byte 0
row_21_chars_end_idx:   .byte 0
row_21_chars_buffer:    .fill 40,0
row_22_chars_start_idx: .byte 0
row_22_chars_end_idx:   .byte 0
row_22_chars_buffer:    .fill 40,0
row_23_chars_start_idx: .byte 0
row_23_chars_end_idx:   .byte 0
row_23_chars_buffer:    .fill 40,0
row_24_chars_start_idx: .byte 0
row_24_chars_end_idx:   .byte 0
row_24_chars_buffer:    .fill 40,0

// The X register is used for the circular buffer indexing.
// The Y register is the data stored in the buffer at the X location.
.macro shift_row_left(scr_row, row_start_idx, row_end_idx, row_buffer) {
  ldx row_start_idx
  cpx row_end_idx
  beq shift_row_left_done // no characters in the ring buffer

  // special case the first character since it might be rolling off the screen
  // and we might need to move the ring buffer's start position. we don't
  // do that check on all the other characters since they won't be
  // moving off the screen.
  ldy row_buffer, X
  bne shift_row_left_loop
  // if here, the first character is on the far left of the screen
  inx
  cpx #40
  bne nowrap
  ldx #0
  stx row_start_idx
  beq shift_row_left_loop
nowrap:
  stx row_start_idx
shift_row_left_loop:
  cpx row_end_idx
  beq shift_row_left_loop_done // no characters remaining in ring buffer
  ldy row_buffer, X // get the column index stored in the ring buffer
  lda scr_row, Y
  sta scr_row-1, Y // updates the screen
  dec row_buffer, x // dec the value at the current index in the ring buffer
  inx
  cpx #40
  bne shift_row_left_loop
  ldx #0
  beq shift_row_left_loop
shift_row_left_loop_done:

  // blank out the character at the end of the ring buffer since we're
  //   shifting the screen left
  // TODO: if the last char is on the far right of the screen
  //   then we could optimize this by not blanking out that char since
  //   we might be writing a new char into it anyway. This might be
  //   worse though since most of the time there won't be a char coming
  //   onto the screen for a row and the checking could cost more anyway
  lda #0
  // y should still have the value from the end index
  sta scr_row, y
shift_row_left_done:
}

shift_screen_left:
  shift_row_left(1144, row_3_chars_start_idx, row_3_chars_end_idx, row_3_chars_buffer)
  rts

// // modifies XXXX
// .macro draw_row(scr_row, row_INDICES, row_BUFFER) {
//   ldy row_INDICES+1
//   ldx row_INDICES
//   beq draw_row_loop_done // empty row

// draw_row_loop:
//   lda row_BUFFER, X
//   sta 
//   dey
//   inx
//   cpx #40



// draw_row_loop_done:

// draw_screen:
//   draw_row($0400, ROW_3_CHARS_INDICES, ROW_3_CHARS_BUFFER)