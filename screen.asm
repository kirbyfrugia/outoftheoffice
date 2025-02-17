.var SCR_tmp_var0              = $54
.var SCR_scroll_in             = $56
.var SCR_scroll_out            = $57
.var SCR_scroll_register       = $58
.var SCR_scroll_offset         = $59
.var SCR_objects_ptr           = $43 // and $44


// How scrolling works:
//   You pass in the amount of pixels to scroll.
//   Uses the hardware register to scroll that many pixels, one at a time
//   If, during the scrolling, the scroll register maxes out,
//     then it triggers a copy of characters one character over
//     to the left or right depending on the direction of the scroll
//   It will then continue scrolling pixel by pixel until it has scrolled
//     the amount requested or reached the end or beginning of the level.

// affects A,X,Y
// inputs:
//   SCR_scroll_in - the amount to scroll
// outputs:
//   SCR_scroll_out - the amount actually scrolled
SCR_scroll_left:
  lda #0
  sta SCR_scroll_out
  ldx SCR_scroll_in
  beq SCR_scroll_left_done
SCR_scroll_left_loop:
  lda SCR_scroll_offset
  clc
  adc #1
  cmp #8
  beq SCR_scroll_left_redraw // scroll register at max, so move chars on screen
  sta SCR_scroll_offset
  dec SCR_scroll_register
  jmp SCR_scroll_left_next
SCR_scroll_left_redraw:  
  lda SCR_first_x+1
  cmp SCR_max_column0+1
  bcc SCR_scroll_left_redrawok
  lda SCR_first_x
  cmp SCR_max_column0
  bcc SCR_scroll_left_redrawok
  bcs SCR_scroll_left_done
SCR_scroll_left_redrawok:
  inc tmp1 // for logging, TODO: remove
  lda #0
  sta SCR_scroll_offset
  lda #%00000111
  sta SCR_scroll_register
  stx SCR_tmp_var0
  jsr SCR_move_screen_left
  ldx SCR_tmp_var0
SCR_scroll_left_next:
  inc SCR_scroll_out
  dex
  bne SCR_scroll_left_loop
SCR_scroll_left_done:
  lda $d016
  and #%11110000
  ora SCR_scroll_register
  sta $d016
  rts

// affects A,X,Y
// inputs:
//   SCR_scroll_in - the amount to scroll
// outputs:
//   SCR_scroll_out - the amount actually scrolled
SCR_scroll_right:
  lda #0
  sta SCR_scroll_out
  ldx SCR_scroll_in
  beq SCR_scroll_right_done
SCR_scroll_right_loop:
  lda SCR_scroll_offset
  sec
  sbc #1
  bmi SCR_scroll_right_redraw
  sta SCR_scroll_offset
  inc SCR_scroll_register
  jmp SCR_scroll_right_next
SCR_scroll_right_redraw:  
  lda SCR_first_x
  bne SCR_scroll_right_redrawok
  lda SCR_first_x+1
  bne SCR_scroll_right_redrawok
  beq SCR_scroll_right_done
SCR_scroll_right_redrawok:
  lda #7
  sta SCR_scroll_offset
  lda #%00000000
  sta SCR_scroll_register
  stx SCR_tmp_var0
  jsr SCR_move_screen_right
  ldx SCR_tmp_var0
SCR_scroll_right_next:
  inc SCR_scroll_out
  dex
  bne SCR_scroll_right_loop
SCR_scroll_right_done:
  lda $d016
  and #%11110000
  ora SCR_scroll_register
  sta $d016
  rts

// // TODO: deal with start and end of level
// SCR_scroll_left:
//   lda SCR_scroll_offset
//   clc
//   adc SCR_scroll_in
//   cmp #8
//   bcs SCR_scroll_left_shift
//   sta SCR_scroll_offset
//   jmp SCR_scroll_leftd
// SCR_scroll_left_shift:
//   // if here, wrapped scroll register.
//   // The new position is the old scroll offset + amount scrolled.
//   // Move the screen one character left and subtract a char width
//   //   to set the scroll offset to where it ought to be.
//   // But first check to see if shifting the screen one character
//   //   left is even possible.
  
//   sec
//   sbc #8
//   sta SCR_scroll_offset
//   jsr move_screen_left
//   inc SCR_first_x
//   bne SCR_scroll_leftd
//   inc SCR_first_x+1
// SCR_scroll_leftd:
//   lda #7
//   sec
//   sbc SCR_scroll_offset
//   sta SCR_scroll_register
//   lda $d016
//   and #%11110000
//   ora SCR_scroll_register
//   sta $d016
//   rts

// SCR_scroll_right:
//   lda SCR_scroll_offset
//   sec
//   sbc SCR_scroll_in
//   bmi SCR_scroll_right_shift
//   sta SCR_scroll_offset
//   jmp SCR_scroll_rightd
// SCR_scroll_right_shift:
//   sec
//   sbc #8
//   sta SCR_scroll_offset
//   jsr move_screen_right
//   inc SCR_first_x
//   bne SCR_scroll_rightd
//   inc SCR_first_x+1
// SCR_scroll_rightd:
//   lda #7
//   sec
//   sbc SCR_scroll_offset
//   sta SCR_scroll_register
//   lda $d016
//   and #%11110000
//   ora SCR_scroll_register
//   sta $d016
//   rts


SCR_move_screen_left:
  ldx #0
msl_loop:
  lda 1145, x
  sta 1144, x
  lda 1185, x
  sta 1184, x
  lda 1225, x
  sta 1224, x
  lda 1265, x
  sta 1264, x
  lda 1305, x
  sta 1304, x
  lda 1345, x
  sta 1344, x
  lda 1385, x
  sta 1384, x
  lda 1425, x
  sta 1424, x
  lda 1465, x
  sta 1464, x
  lda 1505, x
  sta 1504, x
  lda 1545, x
  sta 1544, x
  lda 1585, x
  sta 1584, x
  lda 1625, x
  sta 1624, x
  lda 1665, x
  sta 1664, x
  lda 1705, x
  sta 1704, x
  lda 1745, x
  sta 1744, x
  lda 1785, x
  sta 1784, x
  lda 1825, x
  sta 1824, x
  lda 1865, x
  sta 1864, x
  lda 1905, x
  sta 1904, x
  lda 1945, x
  sta 1944, x
  lda 1985, x
  sta 1984, x

  lda 55417, x
  sta 55416, x
  lda 55457, x
  sta 55456, x
  lda 55497, x
  sta 55496, x
  lda 55537, x
  sta 55536, x
  lda 55577, x
  sta 55576, x
  lda 55617, x
  sta 55616, x
  lda 55657, x
  sta 55656, x
  lda 55697, x
  sta 55696, x
  lda 55737, x
  sta 55736, x
  lda 55777, x
  sta 55776, x
  lda 55817, x
  sta 55816, x
  lda 55857, x
  sta 55856, x
  lda 55897, x
  sta 55896, x
  lda 55937, x
  sta 55936, x
  lda 55977, x
  sta 55976, x
  lda 56017, x
  sta 56016, x
  lda 56057, x
  sta 56056, x
  lda 56097, x
  sta 56096, x
  lda 56137, x
  sta 56136, x
  lda 56177, x
  sta 56176, x
  lda 56217, x
  sta 56216, x
  lda 56257, x
  sta 56256, x

  inx
  cpx #39
  beq msl_loop_done
  jmp msl_loop
msl_loop_done:
  inc SCR_first_x
  rts

SCR_move_screen_right:
  ldx #38
msr_loop:
  lda 1144, x
  sta 1145, x
  lda 1184, x
  sta 1185, x
  lda 1224, x
  sta 1225, x
  lda 1264, x
  sta 1265, x
  lda 1304, x
  sta 1305, x
  lda 1344, x
  sta 1345, x
  lda 1384, x
  sta 1385, x
  lda 1424, x
  sta 1425, x
  lda 1464, x
  sta 1465, x
  lda 1504, x
  sta 1505, x
  lda 1544, x
  sta 1545, x
  lda 1584, x
  sta 1585, x
  lda 1624, x
  sta 1625, x
  lda 1664, x
  sta 1665, x
  lda 1704, x
  sta 1705, x
  lda 1744, x
  sta 1745, x
  lda 1784, x
  sta 1785, x
  lda 1824, x
  sta 1825, x
  lda 1864, x
  sta 1865, x
  lda 1904, x
  sta 1905, x
  lda 1944, x
  sta 1945, x
  lda 1984, x
  sta 1985, x

  lda 55416, x
  sta 55417, x
  lda 55456, x
  sta 55457, x
  lda 55496, x
  sta 55497, x
  lda 55536, x
  sta 55537, x
  lda 55576, x
  sta 55577, x
  lda 55616, x
  sta 55617, x
  lda 55656, x
  sta 55657, x
  lda 55696, x
  sta 55697, x
  lda 55736, x
  sta 55737, x
  lda 55776, x
  sta 55777, x
  lda 55816, x
  sta 55817, x
  lda 55856, x
  sta 55857, x
  lda 55896, x
  sta 55897, x
  lda 55936, x
  sta 55937, x
  lda 55976, x
  sta 55977, x
  lda 56016, x
  sta 56017, x
  lda 56056, x
  sta 56057, x
  lda 56096, x
  sta 56097, x
  lda 56136, x
  sta 56137, x
  lda 56176, x
  sta 56177, x
  lda 56216, x
  sta 56217, x
  lda 56256, x
  sta 56257, x

  dex
  bmi msr_loop_done
  jmp msr_loop
msr_loop_done:
  dec SCR_first_x
  rts



SCR_max_column0:    .byte 0,0
SCR_first_x:        .byte 0,0
SCR_last_x:         .byte 0,0
SCR_visible_obj:    .byte 0