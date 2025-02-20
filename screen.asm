.var SCR_tmp_var0              = $54
.var SCR_scroll_in             = $56
.var SCR_scroll_out            = $57
.var SCR_scroll_register       = $58
.var SCR_scroll_offset         = $59
.var SCR_objects_ptr           = $43 // and $44

// Memory map
//   Front buffer:
//     $0400-$07e7 - video matrix 40x25
//     $07f8-$07ff - sprite data pointers
//   Back buffer:
//     $0800-$0be7 - video matrix 40x25
//     $0bf8-$0bff - sprite data pointers
//   Sprite data
//     $0c00-$0dff - sprite data
//   Level data
//     $1ffe-$1fff - just used to store the prg load location, ignored
//     $2000-$27ff - character set
//     $2800-$28ff - character attribs
//     $2900-$2cff - tile set
//     $2d00-$36ff - level (max 256 tiles x 10 rows = 2560 bytes)
//   Scratch space
//     $4000 - $4fff
//   Game program
//     $8000 - ?
.var SCR_charset_prg    = $1ffe
.var SCR_charset        = $2000
.var SCR_char_attribs   = $2800
.var SCR_raw_tiles      = $2900
.var SCR_tiles_ul       = $2900
.var SCR_tiles_ur       = $2a00
.var SCR_tiles_ll       = $2b00
.var SCR_tiles_lr       = $2c00
.var SCR_level_tiles    = $2d00
.var SCR_scratch        = $4000
.var SCR_TEST_MAP_WIDTH = 256

// X holds the tile index
// Y holds the screen column
.macro SCR_draw_tile(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda SCR_tiles_ul, x
  sta scr_row_upper, y
  lda SCR_tiles_ur, x
  sta scr_row_upper+1, y
  lda SCR_tiles_ll, x
  sta scr_row_lower, y
  lda SCR_tiles_lr, x
  sta scr_row_lower+1, y
  pla
  tax
}

// X holds the tile index
// Y holds the screen column
.macro SCR_draw_tile_left(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda SCR_tiles_ul, x
  sta scr_row_upper, y
  lda SCR_tiles_ll, x
  sta scr_row_lower, y
  pla
  tax
}

// X holds the tile index
// Y holds the screen column
.macro SCR_draw_tile_right(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda SCR_tiles_ur, x
  sta scr_row_upper, y
  lda SCR_tiles_lr, x
  sta scr_row_lower, y
  pla
  tax
}

.macro SCR_update_scroll_register() {
  lda $d016
  and #%11110000
  ora SCR_scroll_register
  sta $d016
}


SCR_loadmap:
  // TODO: don't hard-code the device number
  ldx #8
  stx fdev

  ldy #0
lm_fname_loop:
  lda str_level1,y
  beq lm_fname_loop_done
  sta fname,y
  iny
  bne lm_fname_loop
lm_fname_loop_done:
  sty fnamelen

  // load main data
  lda #<SCR_charset_prg
  sta zpb0
  lda #>SCR_charset_prg
  sta zpb1 
  jsr fload
  lda fstatus
  beq loadok
  jmp loaderr
loadok:
  jmp loadd
loaderr:
  // TODO: something better
loadd:

  // now switch up tile format

  // copy to scratch space
  lda #<SCR_raw_tiles
  sta $fb
  lda #>SCR_raw_tiles
  sta $fc

  lda #<SCR_scratch
  sta $fd
  lda #>SCR_scratch
  sta $fe

  lda #$00
  sta $bb
  lda #$04
  sta $bc
  jsr copy
  ldx #0
  ldy #0
lm_copy_tile_1:
  lda SCR_scratch, y
  sta SCR_tiles_ul, x
  iny
  lda SCR_scratch, y
  sta SCR_tiles_ur, x
  iny
  lda SCR_scratch, y
  sta SCR_tiles_ll, x
  iny
  lda SCR_scratch, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_1
lm_copy_tile_2:
  lda SCR_scratch+$0100, y
  sta SCR_tiles_ul, x
  iny
  lda SCR_scratch+$0100, y
  sta SCR_tiles_ur, x
  iny
  lda SCR_scratch+$0100, y
  sta SCR_tiles_ll, x
  iny
  lda SCR_scratch+$0100, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_2
lm_copy_tile_3:
  lda SCR_scratch+$0200, y
  sta SCR_tiles_ul, x
  iny
  lda SCR_scratch+$0200, y
  sta SCR_tiles_ur, x
  iny
  lda SCR_scratch+$0200, y
  sta SCR_tiles_ll, x
  iny
  lda SCR_scratch+$0200, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_3
lm_copy_tile_4:
  lda SCR_scratch+$0300, y
  sta SCR_tiles_ul, x
  iny
  lda SCR_scratch+$0300, y
  sta SCR_tiles_ur, x
  iny
  lda SCR_scratch+$0300, y
  sta SCR_tiles_ll, x
  iny
  lda SCR_scratch+$0300, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_4
  rts

SCR_make_test_tiles:
  ldx #0
  ldy #0
mtt_loop:
  tya
  sta SCR_tiles_ul, x
  sta SCR_tiles_ur, x
  sta SCR_tiles_ll, x
  sta SCR_tiles_lr, x
  cpy #26
  bne mtt_nowrap
  ldy #0
mtt_nowrap:
  iny
  inx
  bne mtt_loop
  // replace tile zero with a space
  lda #32
  sta SCR_tiles_ul
  sta SCR_tiles_ur
  sta SCR_tiles_ll
  sta SCR_tiles_lr
  rts

SCR_make_test_map:
  ldx #0
  lda #0
mtm_loop: // fill the map with the empty tile (tile id zero)
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8), x
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9), x
  bne mtm_nowrap
mtm_nowrap:
  inx
  bne mtm_loop
  ldx #0
  lda #1
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0), x
  lda #2
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9), x
  
  ldx #10
  lda #3
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0), x
  lda #4
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9), x

  ldx #18
  lda #5
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0), x
  lda #6
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9), x

  ldx #19
  lda #7
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0), x
  lda #8
  sta SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9), x
  rts

// load_tiles:
//   ldx #8
//   stx fdev

//   ldy #0
// load_tiles_fname_loop:
//   lda str_level1_tiles,y
//   beq load_tiles_loop_done
//   sta fname,y
//   iny
//   bne load_tiles_fname_loop
// load_tiles_:
//   sty fnamelen

//   // load main data
//   lda #<filedatas
//   sta zpb0
//   lda #>filedatas
//   sta zpb1 
//   jsr fload
//   lda fstatus
//   beq loadok
//   jmp loaderr
// loadok:
//   rts

// .macro draw_tile_row(scr_row_upper, scr_row_lower, map_data_tile_row) {
//   ldx #20
// draw_tile_row_loop:

//   dex
//   bne draw_tile_row_loop
// }


SCR_draw_screen:
  ldx SCR_tile_last_visible
  ldy #38 // screen column
ds_loop:
  SCR_draw_tile(1144, 1184, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile(1224, 1264, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile(1304, 1344, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile(1384, 1424, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3)) 
  SCR_draw_tile(1464, 1504, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile(1544, 1584, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile(1624, 1664, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile(1704, 1744, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile(1784, 1824, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile(1864, 1904, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #102
  sta 1944, y
  sta 1945, y
  sta 2968, y
  sta 2969, y
  lda #102
  sta 1984, y
  sta 1985, y
  sta 3008, y
  sta 3009, y
  lda #11
  sta 56216, y
  sta 56217, y
  sta 56256, y
  sta 56257, y
  sta 57240, y
  sta 57241, y
  sta 57280, y
  sta 57281, y
ds_loop_end:
  dex
  bmi ds_done
  dey
  dey
  jmp ds_loop
ds_done:
  rts

SCR_init_screen:
  lda #0
  sta SCR_buffer_flag
  sta SCR_buffer_ready
  lda #0
  sta SCR_scroll_offset
  lda #%00000111
  sta SCR_scroll_register

  lda $d016
  and #%11110000 // enable smooth scrolling
  ora SCR_scroll_register  // set initial scroll
  sta $d016

  lda #0
  sta SCR_tile_first_visible
  sta SCR_tile_offset
  lda #19
  sta SCR_tile_last_visible
  rts

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
  lda SCR_column_first_visible+1
  cmp SCR_column_first_visible_max+1
  bcc SCR_scroll_left_redrawok
  lda SCR_column_first_visible
  cmp SCR_column_first_visible_max
  bcc SCR_scroll_left_redrawok
  bcs SCR_scroll_left_done
SCR_scroll_left_redrawok:
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
  lda SCR_column_first_visible
  bne SCR_scroll_right_redrawok
  lda SCR_column_first_visible+1
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
  rts

SCR_move_color_left:
  ldx #0
mcl_loop:
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

  inx
  cpx #39
  beq mcl_loop_done
  jmp mcl_loop
mcl_loop_done:
  rts

SCR_move_screen_left:
  lda #%00000001
  sta SCR_color_flag
  ldx #0
  lda SCR_buffer_flag
  beq msl_char_loop_f2b_loop
  jmp msl_char_loop_b2f_loop
msl_char_loop_f2b_loop:
  lda 1145, x
  sta 2168, x
  lda 1185, x
  sta 2208, x
  lda 1225, x
  sta 2248, x
  lda 1265, x
  sta 2288, x
  lda 1305, x
  sta 2328, x
  lda 1345, x
  sta 2368, x
  lda 1385, x
  sta 2408, x
  lda 1425, x
  sta 2448, x
  lda 1465, x
  sta 2488, x
  lda 1505, x
  sta 2528, x
  lda 1545, x
  sta 2568, x
  lda 1585, x
  sta 2608, x
  lda 1625, x
  sta 2648, x
  lda 1665, x
  sta 2688, x
  lda 1705, x
  sta 2728, x
  lda 1745, x
  sta 2768, x
  lda 1785, x
  sta 2808, x
  lda 1825, x
  sta 2848, x
  lda 1865, x
  sta 2888, x
  lda 1905, x
  sta 2928, x

  inx
  cpx #39
  beq msl_fill_right_side_back
  jmp msl_char_loop_f2b_loop
msl_fill_right_side_back:
  // shifted all the screen chars, now let's draw the new right column
  ldy #39
  lda SCR_tile_offset
  bne msl_draw_right_side_back
  jmp msl_load_new_tile_back
msl_draw_right_side_back:
  inc SCR_tile_first_visible
  ldx SCR_tile_last_visible
  SCR_draw_tile_right(2168, 2208, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_right(2248, 2288, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_right(2328, 2368, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_right(2408, 2448, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_right(2488, 2528, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_right(2568, 2608, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_right(2648, 2688, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_right(2728, 2768, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_right(2808, 2848, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_right(2888, 2928, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #0
  sta SCR_tile_offset
  jmp msl_loop_done
msl_load_new_tile_back:
  inc SCR_tile_last_visible
  ldx SCR_tile_last_visible
  SCR_draw_tile_left(2168, 2208, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_left(2248, 2288, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_left(2328, 2368, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_left(2408, 2448, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_left(2488, 2528, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_left(2568, 2608, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_left(2648, 2688, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_left(2728, 2768, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_left(2808, 2848, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_left(2888, 2928, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #1
  sta SCR_tile_offset
  jmp msl_loop_done
msl_char_loop_b2f_loop:
  lda 2169, x
  sta 1144, x
  lda 2209, x
  sta 1184, x
  lda 2249, x
  sta 1224, x
  lda 2289, x
  sta 1264, x
  lda 2329, x
  sta 1304, x
  lda 2369, x
  sta 1344, x
  lda 2409, x
  sta 1384, x
  lda 2449, x
  sta 1424, x
  lda 2489, x
  sta 1464, x
  lda 2529, x
  sta 1504, x
  lda 2569, x
  sta 1544, x
  lda 2609, x
  sta 1584, x
  lda 2649, x
  sta 1624, x
  lda 2689, x
  sta 1664, x
  lda 2729, x
  sta 1704, x
  lda 2769, x
  sta 1744, x
  lda 2809, x
  sta 1784, x
  lda 2849, x
  sta 1824, x
  lda 2889, x
  sta 1864, x
  lda 2929, x
  sta 1904, x

  inx
  cpx #39
  beq msl_fill_right_side_front
  jmp msl_char_loop_b2f_loop
msl_fill_right_side_front:
  // shifted all the screen chars, now let's draw the new right column
  ldy #39
  lda SCR_tile_offset
  bne msl_draw_right_side_front
  jmp msl_load_new_tile_front
msl_draw_right_side_front:
  inc SCR_tile_first_visible
  ldx SCR_tile_last_visible
  SCR_draw_tile_right(1144, 1184, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_right(1224, 1264, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_right(1304, 1344, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_right(1384, 1424, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3)) 
  SCR_draw_tile_right(1464, 1504, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_right(1544, 1584, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_right(1624, 1664, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_right(1704, 1744, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_right(1784, 1824, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_right(1864, 1904, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #0
  sta SCR_tile_offset
  jmp msl_loop_done
msl_load_new_tile_front:
  inc SCR_tile_last_visible
  ldx SCR_tile_last_visible
  SCR_draw_tile_left(1144, 1184, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_left(1224, 1264, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_left(1304, 1344, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_left(1384, 1424, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3)) 
  SCR_draw_tile_left(1464, 1504, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_left(1544, 1584, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_left(1624, 1664, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_left(1704, 1744, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_left(1784, 1824, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_left(1864, 1904, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #1
  sta SCR_tile_offset
msl_loop_done:
  inc SCR_column_first_visible
  bne msl_done
  inc SCR_column_first_visible+1
msl_done:
  lda #1
  sta SCR_buffer_ready
  rts

SCR_move_color_right:
  ldx #38
mcr_loop:
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
  dex
  bmi mcr_loop_done
  jmp mcr_loop
mcr_loop_done:
  rts

SCR_move_screen_right:
  lda #%00000010
  sta SCR_color_flag
  ldx #38
  lda SCR_buffer_flag
  beq msr_char_loop_f2b_loop
  jmp msr_char_loop_b2f_loop
msr_char_loop_f2b_loop:
  lda 1144, x
  sta 2169, x
  lda 1184, x
  sta 2209, x
  lda 1224, x
  sta 2249, x
  lda 1264, x
  sta 2289, x
  lda 1304, x
  sta 2329, x
  lda 1344, x
  sta 2369, x
  lda 1384, x
  sta 2409, x
  lda 1424, x
  sta 2449, x
  lda 1464, x
  sta 2489, x
  lda 1504, x
  sta 2529, x
  lda 1544, x
  sta 2569, x
  lda 1584, x
  sta 2609, x
  lda 1624, x
  sta 2649, x
  lda 1664, x
  sta 2689, x
  lda 1704, x
  sta 2729, x
  lda 1744, x
  sta 2769, x
  lda 1784, x
  sta 2809, x
  lda 1824, x
  sta 2849, x
  lda 1864, x
  sta 2889, x
  lda 1904, x
  sta 2929, x
  dex
  bmi msr_fill_left_side_back
  jmp msr_char_loop_f2b_loop
msr_fill_left_side_back:
  // shifted all the screen chars, now let's draw the new left column
  ldy #0
  lda SCR_tile_offset
  bne msr_draw_left_side_back
  jmp msr_load_new_tile_back
msr_draw_left_side_back:
  dec SCR_tile_last_visible
  ldx SCR_tile_first_visible
  SCR_draw_tile_left(2168, 2208, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_left(2248, 2288, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_left(2328, 2368, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_left(2408, 2448, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_left(2488, 2528, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_left(2568, 2608, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_left(2648, 2688, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_left(2728, 2768, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_left(2808, 2848, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_left(2888, 2928, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #0
  sta SCR_tile_offset
  jmp msr_loop_done
msr_load_new_tile_back:
  dec SCR_tile_first_visible
  ldx SCR_tile_first_visible
  SCR_draw_tile_right(2168, 2208, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_right(2248, 2288, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_right(2328, 2368, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_right(2408, 2448, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_right(2488, 2528, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_right(2568, 2608, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_right(2648, 2688, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_right(2728, 2768, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_right(2808, 2848, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_right(2888, 2928, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #1
  sta SCR_tile_offset
  jmp msr_loop_done
msr_char_loop_b2f_loop:
  lda 2168, x
  sta 1145, x
  lda 2208, x
  sta 1185, x
  lda 2248, x
  sta 1225, x
  lda 2288, x
  sta 1265, x
  lda 2328, x
  sta 1305, x
  lda 2368, x
  sta 1345, x
  lda 2408, x
  sta 1385, x
  lda 2448, x
  sta 1425, x
  lda 2488, x
  sta 1465, x
  lda 2528, x
  sta 1505, x
  lda 2568, x
  sta 1545, x
  lda 2608, x
  sta 1585, x
  lda 2648, x
  sta 1625, x
  lda 2688, x
  sta 1665, x
  lda 2728, x
  sta 1705, x
  lda 2768, x
  sta 1745, x
  lda 2808, x
  sta 1785, x
  lda 2848, x
  sta 1825, x
  lda 2888, x
  sta 1865, x
  lda 2928, x
  sta 1905, x
  dex
  bmi msr_fill_left_side_front
  jmp msr_char_loop_b2f_loop
msr_fill_left_side_front:
  // shifted all the screen chars, now let's draw the new left column
  ldy #0
  lda SCR_tile_offset
  bne msr_draw_left_side_front
  jmp msr_load_new_tile_front
msr_draw_left_side_front:
  dec SCR_tile_last_visible
  ldx SCR_tile_first_visible
  SCR_draw_tile_left(1144, 1184, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_left(1224, 1264, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_left(1304, 1344, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_left(1384, 1424, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_left(1464, 1504, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_left(1544, 1584, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_left(1624, 1664, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_left(1704, 1744, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_left(1784, 1824, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_left(1864, 1904, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #0
  sta SCR_tile_offset
  jmp msr_loop_done
msr_load_new_tile_front:
  dec SCR_tile_first_visible
  ldx SCR_tile_first_visible
  SCR_draw_tile_right(1144, 1184, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*0))
  SCR_draw_tile_right(1224, 1264, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*1))
  SCR_draw_tile_right(1304, 1344, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*2))
  SCR_draw_tile_right(1384, 1424, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*3))
  SCR_draw_tile_right(1464, 1504, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*4))
  SCR_draw_tile_right(1544, 1584, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*5))
  SCR_draw_tile_right(1624, 1664, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*6))
  SCR_draw_tile_right(1704, 1744, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*7))
  SCR_draw_tile_right(1784, 1824, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*8))
  SCR_draw_tile_right(1864, 1904, SCR_level_tiles+(SCR_TEST_MAP_WIDTH*9))
  lda #1
  sta SCR_tile_offset
msr_loop_done:
  lda SCR_column_first_visible
  sec
  sbc #1
  sta SCR_column_first_visible
  lda SCR_column_first_visible+1
  sbc #0
  sta SCR_column_first_visible+1
msr_done:
  lda #1
  sta SCR_buffer_ready
  rts



SCR_column_first_visible_max:    .byte 0,0
SCR_column_first_visible:        .byte 0,0

// TODO: move this to the zero page
SCR_tile_first_visible:          .byte 0
SCR_tile_last_visible:           .byte 0
SCR_tile_offset:                 .byte 0
SCR_buffer_flag:                 .byte 0
SCR_buffer_ready:                .byte 0
SCR_color_flag:                  .byte 0