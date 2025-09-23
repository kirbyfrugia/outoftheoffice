.const SCR_COLLISION_MASK_LEFT    = %10000000
.const SCR_COLLISION_MASK_RIGHT   = %01000000
.const SCR_COLLISION_MASK_TOP     = %00100000
.const SCR_COLLISION_MASK_BOTTOM  = %00010000

// Y holds the tile index
// X holds the screen column
.macro SCR_draw_tile(scr_row_upper, scr_row_lower, row_addr) {
  tya
  pha
  lda (row_addr), y
  tay
  lda SCR_tiles_ul, y
  sta scr_row_upper, x
  lda SCR_tiles_ur, y
  sta scr_row_upper+1, x
  lda SCR_tiles_ll, y
  sta scr_row_lower, x
  lda SCR_tiles_lr, y
  sta scr_row_lower+1, x
  pla
  tay
}

// Y holds the tile index
// X holds the screen column
.macro SCR_draw_tile_left(scr_row_upper, scr_row_lower, row_addr) {
  tya
  pha
  lda (row_addr), y
  tay
  lda SCR_tiles_ul, y
  sta scr_row_upper, x
  lda SCR_tiles_ll, y
  sta scr_row_lower, x
  pla
  tay
}

// Y holds the tile index
// X holds the screen column
.macro SCR_draw_tile_right(scr_row_upper, scr_row_lower, row_addr) {
  tya
  pha
  lda (row_addr), y
  tay
  lda SCR_tiles_ur, y
  sta scr_row_upper, x
  lda SCR_tiles_lr, y
  sta scr_row_lower, x
  pla
  tay
}

.macro SCR_draw_color_tile(color_row_upper, color_row_lower, row_addr) {
  tya
  pha
  lda (row_addr), y
  tay
  lda SCR_char_tileset_attrib, y
  sta color_row_upper, x
  sta color_row_upper+1, x
  sta color_row_lower, x
  sta color_row_lower+1, x
  pla
  tay
}

.macro SCR_draw_color_tile_half(color_row_upper, color_row_lower, row_addr) {
  tya
  pha
  lda (row_addr), y
  tay
  lda SCR_char_tileset_attrib, y
  sta color_row_upper, x
  sta color_row_lower, x
  pla
  tay
}

.macro SCR_update_scroll_register() {
  lda VIC_HCONTROL_REG
  and #%11010000
  ora SCR_scroll_register
  sta VIC_HCONTROL_REG
}


SCR_update_tile_addr:
  ldx #0
  lda #<SCR_level_tiles
  sta $20
  sta SCR_rowptrs_lo, x
  lda #>SCR_level_tiles
  sta $21
  sta SCR_rowptrs_hi, x

  inx
  lda $20
  clc
  adc SCR_tile_level_width
  sta $22
  sta SCR_rowptrs_lo, x
  lda $21
  adc #0
  sta $23
  sta SCR_rowptrs_hi, x

  inx
  lda $22
  clc
  adc SCR_tile_level_width
  sta $24
  sta SCR_rowptrs_lo, x
  lda $23
  adc #0
  sta $25
  sta SCR_rowptrs_hi, x

  inx
  lda $24
  clc
  adc SCR_tile_level_width
  sta $26
  sta SCR_rowptrs_lo, x
  lda $25
  adc #0
  sta $27
  sta SCR_rowptrs_hi, x

  inx
  lda $26
  clc
  adc SCR_tile_level_width
  sta $28
  sta SCR_rowptrs_lo, x
  lda $27
  adc #0
  sta $29
  sta SCR_rowptrs_hi, x

  inx
  lda $28
  clc
  adc SCR_tile_level_width
  sta $2a
  sta SCR_rowptrs_lo, x
  lda $29
  adc #0
  sta $2b
  sta SCR_rowptrs_hi, x

  inx
  lda $2a
  clc
  adc SCR_tile_level_width
  sta $2c
  sta SCR_rowptrs_lo, x
  lda $2b
  adc #0
  sta $2d
  sta SCR_rowptrs_hi, x

  inx
  lda $2c
  clc
  adc SCR_tile_level_width
  sta $2e
  sta SCR_rowptrs_lo, x
  lda $2d
  adc #0
  sta $2f
  sta SCR_rowptrs_hi, x

  inx
  lda $2e
  clc
  adc SCR_tile_level_width
  sta $30
  sta SCR_rowptrs_lo, x
  lda $2f
  adc #0
  sta $31
  sta SCR_rowptrs_hi, x

  inx
  lda $30
  clc
  adc SCR_tile_level_width
  sta $32
  sta SCR_rowptrs_lo, x
  lda $31
  adc #0
  sta $33
  sta SCR_rowptrs_hi, x

  rts

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
  beq lm_loadok
  jmp lm_loaderr
lm_loadok:
  jmp lm_loadd
lm_loaderr:
  // TODO: something better
lm_loadd:

  // now switch up tile format for tiles

  // copy to scratch space
  lda #<SCR_raw_tiles
  sta $fb
  lda #>SCR_raw_tiles
  sta $fc

  lda #<SCRATCH_SPACE
  sta $fd
  lda #>SCRATCH_SPACE
  sta $fe

  lda #$00
  sta $bb
  lda #$04
  sta $bc
  jsr copy
  ldx #0
  ldy #0
lm_copy_tile_1:
  lda SCRATCH_SPACE, y
  sta SCR_tiles_ul, x
  iny
  lda SCRATCH_SPACE, y
  sta SCR_tiles_ur, x
  iny
  lda SCRATCH_SPACE, y
  sta SCR_tiles_ll, x
  iny
  lda SCRATCH_SPACE, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_1
lm_copy_tile_2:
  lda SCRATCH_SPACE+$0100, y
  sta SCR_tiles_ul, x
  iny
  lda SCRATCH_SPACE+$0100, y
  sta SCR_tiles_ur, x
  iny
  lda SCRATCH_SPACE+$0100, y
  sta SCR_tiles_ll, x
  iny
  lda SCRATCH_SPACE+$0100, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_2
lm_copy_tile_3:
  lda SCRATCH_SPACE+$0200, y
  sta SCR_tiles_ul, x
  iny
  lda SCRATCH_SPACE+$0200, y
  sta SCR_tiles_ur, x
  iny
  lda SCRATCH_SPACE+$0200, y
  sta SCR_tiles_ll, x
  iny
  lda SCRATCH_SPACE+$0200, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_3
lm_copy_tile_4:
  lda SCRATCH_SPACE+$0300, y
  sta SCR_tiles_ul, x
  iny
  lda SCRATCH_SPACE+$0300, y
  sta SCR_tiles_ur, x
  iny
  lda SCRATCH_SPACE+$0300, y
  sta SCR_tiles_ll, x
  iny
  lda SCRATCH_SPACE+$0300, y
  sta SCR_tiles_lr, x
  inx
  iny
  bne lm_copy_tile_4

  jsr SCR_update_tile_addr
  rts

.macro load_sprite_sheet(fname_ptr, prgloc_lo, prgloc_hi) {
  // TODO: don't hard-code the device number
  ldx #8
  stx fdev

  ldy #0
lss_fname_loop:
  lda fname_ptr,y
  beq lss_fname_loop_done
  sta fname,y
  iny
  bne lss_fname_loop
lss_fname_loop_done:
  sty fnamelen

  // load main data
  lda #prgloc_lo
  sta zpb0
  lda #prgloc_hi
  sta zpb1 
  jsr fload
  lda fstatus
  beq lss_loadok
  jmp lss_loaderr
lss_loadok:
  jmp lss_loadd
lss_loaderr:
  // TODO: something better
lss_loadd:
}

SCR_load_sprite_sheets:
  load_sprite_sheet(str_sprites1, $fe, $0b)
  load_sprite_sheet(str_sprites2, $fe, $1f)
  rts

// clear_screen:
//   ldy #0
// clear_screen_loop:
//   lda #0
//   sta $d800,y
//   sta $d800+$0100,y
//   sta $d800+$0200,y
//   sta $d800+$0300,y

//   lda #69
//   sta $0400,y
//   sta $0400+$0100,y
//   sta $0400+$0200,y
//   sta $0400+$0300,y
//   lda #69
//   sta $0800,y
//   sta $0800+$0100,y
//   sta $0800+$0200,y
//   sta $0800+$0300,y
//   iny
//   bne clear_screen_loop
//   rts

clear_screen:
  lda #<COLOR_MEM
  sta zpb0
  lda #>COLOR_MEM
  sta zpb1

  lda #<SCREEN_MEM1
  sta zpb2
  lda #>SCREEN_MEM1
  sta zpb3

  ldx #24
  ldy #39
clear_screen_loop:
  lda #0
  sta (zpb0), y
  lda #69
  sta (zpb2), y

  dey
  bpl clear_screen_loop
  dex
  bmi clear_screen_done

  ldy #39

  lda zpb0
  clc
  adc #40
  sta zpb0
  lda zpb1
  adc #0
  sta zpb1

  lda zpb2
  clc
  adc #40
  sta zpb2
  lda zpb3
  adc #0
  sta zpb3
  jmp clear_screen_loop
clear_screen_done:
  rts

SCR_init_screen:
  // set the screen buffer to the 1024 buffer
  lda VIC_MEM_CONTROL_REG
  and #%00001111
  ora #%00010000 // screen location 1024, $0400
  sta VIC_MEM_CONTROL_REG

  lda #0
  sta SCR_buffer_flag
  sta SCR_buffer_ready
  sta SCR_color_flag
  sta SCR_direction
  sta SCR_scroll_offset
  sta SCR_scroll_left_amounts_pre
  sta SCR_scroll_left_amounts_post
  sta SCR_scroll_right_amounts_pre
  sta SCR_scroll_right_amounts_post
  lda #%00000111
  sta SCR_scroll_register

  lda VIC_HCONTROL_REG
  and #%11010000 // enable smooth scrolling
  ora SCR_scroll_register  // set initial scroll
  sta VIC_HCONTROL_REG

  lda #0
  sta SCR_first_visible_tile
  sta SCR_tile_offset
  sta SCR_first_visible_column
  sta SCR_first_visible_column+1
  sta SCR_first_visible_column_pixels
  sta SCR_first_visible_column_pixels+1

  lda #<(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels
  lda #>(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels+1

  lda #19
  sta SCR_last_visible_tile
  rts

SCR_swipe_screen:
  ldx #39
SCR_swipe_screen_col:
  lda SCREEN_MEM2+0, x
  sta SCREEN_MEM1+0, x
  lda SCREEN_MEM2+40, x
  sta SCREEN_MEM1+40, x
  lda SCREEN_MEM2+80, x
  sta SCREEN_MEM1+80, x
  lda SCREEN_MEM2+120, x
  sta SCREEN_MEM1+120, x
  lda SCREEN_MEM2+160, x
  sta SCREEN_MEM1+160, x
  lda SCREEN_MEM2+200, x
  sta SCREEN_MEM1+200, x
  lda SCREEN_MEM2+240, x
  sta SCREEN_MEM1+240, x
  lda SCREEN_MEM2+280, x
  sta SCREEN_MEM1+280, x
  lda SCREEN_MEM2+320, x
  sta SCREEN_MEM1+320, x
  lda SCREEN_MEM2+360, x
  sta SCREEN_MEM1+360, x
  lda SCREEN_MEM2+400, x
  sta SCREEN_MEM1+400, x
  lda SCREEN_MEM2+440, x
  sta SCREEN_MEM1+440, x
  lda SCREEN_MEM2+480, x
  sta SCREEN_MEM1+480, x
  lda SCREEN_MEM2+520, x
  sta SCREEN_MEM1+520, x
  lda SCREEN_MEM2+560, x
  sta SCREEN_MEM1+560, x
  lda SCREEN_MEM2+600, x
  sta SCREEN_MEM1+600, x
  lda SCREEN_MEM2+640, x
  sta SCREEN_MEM1+640, x
  lda SCREEN_MEM2+680, x
  sta SCREEN_MEM1+680, x
  lda SCREEN_MEM2+720, x
  sta SCREEN_MEM1+720, x
  lda SCREEN_MEM2+760, x
  sta SCREEN_MEM1+760, x
  lda SCREEN_MEM2+800, x
  sta SCREEN_MEM1+800, x

  lda SCRATCH_SPACE+0, x
  sta COLOR_MEM+0, x
  lda SCRATCH_SPACE+40, x
  sta COLOR_MEM+40, x
  lda SCRATCH_SPACE+80, x
  sta COLOR_MEM+80, x
  lda SCRATCH_SPACE+120, x
  sta COLOR_MEM+120, x
  lda SCRATCH_SPACE+160, x
  sta COLOR_MEM+160, x
  lda SCRATCH_SPACE+200, x
  sta COLOR_MEM+200, x
  lda SCRATCH_SPACE+240, x
  sta COLOR_MEM+240, x
  lda SCRATCH_SPACE+280, x
  sta COLOR_MEM+280, x
  lda SCRATCH_SPACE+320, x
  sta COLOR_MEM+320, x
  lda SCRATCH_SPACE+360, x
  sta COLOR_MEM+360, x
  lda SCRATCH_SPACE+400, x
  sta COLOR_MEM+400, x
  lda SCRATCH_SPACE+440, x
  sta COLOR_MEM+440, x
  lda SCRATCH_SPACE+480, x
  sta COLOR_MEM+480, x
  lda SCRATCH_SPACE+520, x
  sta COLOR_MEM+520, x
  lda SCRATCH_SPACE+560, x
  sta COLOR_MEM+560, x
  lda SCRATCH_SPACE+600, x
  sta COLOR_MEM+600, x
  lda SCRATCH_SPACE+640, x
  sta COLOR_MEM+640, x
  lda SCRATCH_SPACE+680, x
  sta COLOR_MEM+680, x
  lda SCRATCH_SPACE+720, x
  sta COLOR_MEM+720, x
  lda SCRATCH_SPACE+760, x
  sta COLOR_MEM+760, x
  lda SCRATCH_SPACE+800, x
  sta COLOR_MEM+800, x

  dex
  bmi swipe_done
delay_loop:
  lda VIC_RW_RASTER
  cmp #$fa
  bne delay_loop

  jmp SCR_swipe_screen_col
swipe_done:
  rts

// TODO: instead smooth scroll the level entirely?
// wait until we get a raster

SCR_draw_screen:
  ldy SCR_last_visible_tile
  ldx #38 // screen column
ds_loop:
  SCR_draw_tile(2048, 2088, SCR_TILE_ROW_0)
  SCR_draw_tile(2128, 2168, SCR_TILE_ROW_1)
  SCR_draw_tile(2208, 2248, SCR_TILE_ROW_2)
  SCR_draw_tile(2288, 2328, SCR_TILE_ROW_3)
  SCR_draw_tile(2368, 2408, SCR_TILE_ROW_4)
  SCR_draw_tile(2448, 2488, SCR_TILE_ROW_5)
  SCR_draw_tile(2528, 2568, SCR_TILE_ROW_6) 
  SCR_draw_tile(2608, 2648, SCR_TILE_ROW_7)
  SCR_draw_tile(2688, 2728, SCR_TILE_ROW_8)
  SCR_draw_tile(2768, 2808, SCR_TILE_ROW_9)


  // draw color to a scratch space
  SCR_draw_color_tile(SCRATCH_SPACE+0,   SCRATCH_SPACE+40,  SCR_TILE_ROW_0)
  SCR_draw_color_tile(SCRATCH_SPACE+80,  SCRATCH_SPACE+120, SCR_TILE_ROW_1)
  SCR_draw_color_tile(SCRATCH_SPACE+160, SCRATCH_SPACE+200, SCR_TILE_ROW_2)
  SCR_draw_color_tile(SCRATCH_SPACE+240, SCRATCH_SPACE+280, SCR_TILE_ROW_3)
  SCR_draw_color_tile(SCRATCH_SPACE+320, SCRATCH_SPACE+360, SCR_TILE_ROW_4)
  SCR_draw_color_tile(SCRATCH_SPACE+400, SCRATCH_SPACE+440, SCR_TILE_ROW_5)
  SCR_draw_color_tile(SCRATCH_SPACE+480, SCRATCH_SPACE+520, SCR_TILE_ROW_6)
  SCR_draw_color_tile(SCRATCH_SPACE+560, SCRATCH_SPACE+600, SCR_TILE_ROW_7)
  SCR_draw_color_tile(SCRATCH_SPACE+640, SCRATCH_SPACE+680, SCR_TILE_ROW_8)
  SCR_draw_color_tile(SCRATCH_SPACE+720, SCRATCH_SPACE+760, SCR_TILE_ROW_9)

  // bottom two rows
  lda #66
  sta SCREEN_MEM2+20*40,   x
  sta SCREEN_MEM2+20*40+1, x

  lda #69
  sta SCREEN_MEM2+21*40,   x
  sta SCREEN_MEM2+21*40+1, x

  lda #11 // dark grey
  sta SCRATCH_SPACE+20*40,   x
  sta SCRATCH_SPACE+20*40+1, x

  lda #COLOR_HUD_BG
  sta SCRATCH_SPACE+21*40,   x
  sta SCRATCH_SPACE+21*40+1, x

  // // sta 1824, x
  // // sta 1825, x
  // // // sta 2848, x
  // // // sta 2849, x
  // lda #69
  // sta 1864, x
  // sta 1865, x
  // sta 2888, x
  // sta 2889, x
  // lda #11
  // sta 56096, x
  // sta 56097, x
  // lda #COLOR_HUD_BG
  // sta 56136, x
  // sta 56137, x
ds_loop_end:
  dey
  bmi ds_done
  dex
  dex
  jmp ds_loop
ds_done:
  rts


// How scrolling works:
//   You pass in the amount of pixels to scroll.
//   Uses the hardware register to scroll that many pixels, one at a time
//   If, during the scrolling, the scroll register maxes out,
//     then it triggers a copy of characters one character over in the back buffer
//     to the left or right depending on the direction of the scroll
//   It will then continue scrolling pixel by pixel until it has scrolled
//     the amount requested or reached the end or beginning of the level.
//   None of the actual scrolling or buffer swapping happens here. It's done
//     in the IRQ.

// affects A,X,Y
// inputs:
//   SCR_scroll_in - the amount to scroll
// outputs:
//   SCR_scroll_out - the amount actually scrolled
// other:
//   SCR_scroll_offset - maintains amount of scroll (7 - scroll_register)
//   SCR_scroll_left_amounts_pre - amount of pixels hw scrolled before triggering a redraw
//   SCR_scroll_left_amounts_post - amount of pixels hw scrolled after triggering a redraw
SCR_scroll_left:
  ldx #0 // index into which scroll var we're using
  stx SCR_direction // direction we're scrolling, 0 for left
  lda #0
  sta SCR_scroll_redraw_flag
  sta SCR_scroll_out
  ldy SCR_scroll_in
  beq SCR_scroll_leftd
SCR_scroll_left_loop:
  lda SCR_scroll_offset
  clc
  adc #1
  cmp #8
  beq SCR_scroll_left_wrapped // scroll register at max, so move chars on screen
  sta SCR_scroll_offset
  inc SCR_scroll_left_amounts, x
  jmp SCR_scroll_left_next
SCR_scroll_left_wrapped:  
  lda SCR_first_visible_column+1
  cmp SCR_first_visible_column_max+1
  bcc SCR_scroll_left_will_redraw
  lda SCR_first_visible_column
  cmp SCR_first_visible_column_max
  bcc SCR_scroll_left_will_redraw
  bcs SCR_scroll_left_loopd
SCR_scroll_left_will_redraw:
  lda #0
  sta SCR_scroll_offset
  lda #1
  sta SCR_scroll_redraw_flag
  tax // now start tracking scroll amounts in the post-redraw var
  inc SCR_scroll_left_amounts, x
SCR_scroll_left_next:
  inc SCR_scroll_out
  dey
  bne SCR_scroll_left_loop
SCR_scroll_left_loopd:
  lda SCR_scroll_redraw_flag
  beq SCR_scroll_leftd
  // must be done at end so we don't hit a race condition with scrolling
  jsr SCR_move_screen_left
SCR_scroll_leftd:
  rts

SCR_scroll_right:
  ldx #1
  stx SCR_direction // direction we're scrolling, 0 for left
  ldx #0
  lda #0
  sta SCR_scroll_redraw_flag
  sta SCR_scroll_out
  ldy SCR_scroll_in
  beq SCR_scroll_rightd
SCR_scroll_right_loop:
  lda SCR_scroll_offset
  sec
  sbc #1
  bmi SCR_scroll_right_wrapped
  sta SCR_scroll_offset
  inc SCR_scroll_right_amounts, x
  jmp SCR_scroll_right_next
SCR_scroll_right_wrapped:  
  lda SCR_first_visible_column
  bne SCR_scroll_right_will_redraw
  lda SCR_first_visible_column+1
  bne SCR_scroll_right_will_redraw
  beq SCR_scroll_right_loopd
SCR_scroll_right_will_redraw:
  lda #7
  sta SCR_scroll_offset
  lda #1
  sta SCR_scroll_redraw_flag
  tax
  inc SCR_scroll_right_amounts, x
SCR_scroll_right_next:
  inc SCR_scroll_out
  dey
  bne SCR_scroll_right_loop
SCR_scroll_right_loopd:
  lda SCR_scroll_redraw_flag
  beq SCR_scroll_rightd
  // must be done at end so we don't hit a race condition with scrolling
  jsr SCR_move_screen_right
SCR_scroll_rightd:
  rts

SCR_move_color_left_upper:
  ldx #0
mcl_upper_loop:
  lda 55297, x
  sta 55296, x
  lda 55337, x
  sta 55336, x
  lda 55377, x
  sta 55376, x
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

  inx
  cpx #39
  beq mcl_upper_loop_done
  jmp mcl_upper_loop
mcl_upper_loop_done:
  ldx #39
  ldy SCR_last_visible_tile
  SCR_draw_color_tile_half(55296, 55336, SCR_TILE_ROW_0)
  SCR_draw_color_tile_half(55376, 55416, SCR_TILE_ROW_1)
  SCR_draw_color_tile_half(55456, 55496, SCR_TILE_ROW_2)
  SCR_draw_color_tile_half(55536, 55576, SCR_TILE_ROW_3)
  SCR_draw_color_tile_half(55616, 55656, SCR_TILE_ROW_4)
  rts

SCR_move_color_left_lower:
  ldx #0
mcl_lower_loop:
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

  inx
  cpx #39
  beq mcl_lower_loop_done
  jmp mcl_lower_loop
mcl_lower_loop_done:
  ldx #39
  ldy SCR_last_visible_tile
  SCR_draw_color_tile_half(55696, 55736, SCR_TILE_ROW_5)
  SCR_draw_color_tile_half(55776, 55816, SCR_TILE_ROW_6) 
  SCR_draw_color_tile_half(55856, 55896, SCR_TILE_ROW_7)
  SCR_draw_color_tile_half(55936, 55976, SCR_TILE_ROW_8)
  SCR_draw_color_tile_half(56016, 56056, SCR_TILE_ROW_9)
  rts

SCR_move_screen_left:
  lda #%00000001
  sta SCR_color_flag
  ldx #0
  lda SCR_buffer_flag
  beq msl_char_loop_f2b_loop
  jmp msl_char_loop_b2f_loop
msl_char_loop_f2b_loop:
  lda 1025, x
  sta 2048, x
  lda 1065, x
  sta 2088, x
  lda 1105, x
  sta 2128, x
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

  // TODO: this could be faster by decrementing and doing a bmi instead of this
  inx
  cpx #39
  beq msl_fill_right_side_back
  jmp msl_char_loop_f2b_loop
msl_fill_right_side_back:
  // shifted all the screen chars, now let's draw the new right column
  ldx #39
  lda SCR_tile_offset
  bne msl_draw_right_side_back
  jmp msl_load_new_tile_back
msl_draw_right_side_back:
  inc SCR_first_visible_tile
  ldy SCR_last_visible_tile
  SCR_draw_tile_right(2048, 2088, SCR_TILE_ROW_0)
  SCR_draw_tile_right(2128, 2168, SCR_TILE_ROW_1)
  SCR_draw_tile_right(2208, 2248, SCR_TILE_ROW_2)
  SCR_draw_tile_right(2288, 2328, SCR_TILE_ROW_3)
  SCR_draw_tile_right(2368, 2408, SCR_TILE_ROW_4)
  SCR_draw_tile_right(2448, 2488, SCR_TILE_ROW_5)
  SCR_draw_tile_right(2528, 2568, SCR_TILE_ROW_6)
  SCR_draw_tile_right(2608, 2648, SCR_TILE_ROW_7)
  SCR_draw_tile_right(2688, 2728, SCR_TILE_ROW_8)
  SCR_draw_tile_right(2768, 2808, SCR_TILE_ROW_9)

  lda #0
  sta SCR_tile_offset
  jmp msl_loop_done
msl_load_new_tile_back:
  inc SCR_last_visible_tile
  ldy SCR_last_visible_tile
  SCR_draw_tile_left(2048, 2088, SCR_TILE_ROW_0)
  SCR_draw_tile_left(2128, 2168, SCR_TILE_ROW_1)
  SCR_draw_tile_left(2208, 2248, SCR_TILE_ROW_2)
  SCR_draw_tile_left(2288, 2328, SCR_TILE_ROW_3)
  SCR_draw_tile_left(2368, 2408, SCR_TILE_ROW_4)
  SCR_draw_tile_left(2448, 2488, SCR_TILE_ROW_5)
  SCR_draw_tile_left(2528, 2568, SCR_TILE_ROW_6)
  SCR_draw_tile_left(2608, 2648, SCR_TILE_ROW_7)
  SCR_draw_tile_left(2688, 2728, SCR_TILE_ROW_8)
  SCR_draw_tile_left(2768, 2808, SCR_TILE_ROW_9)

  lda #1
  sta SCR_tile_offset
  jmp msl_loop_done
msl_char_loop_b2f_loop:
  lda 2049, x
  sta 1024, x
  lda 2089, x
  sta 1064, x
  lda 2129, x
  sta 1104, x
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

  inx
  cpx #39
  beq msl_fill_right_side_front
  bne msl_char_loop_b2f_loop
msl_fill_right_side_front:
  // shifted all the screen chars, now let's draw the new right column
  ldx #39
  lda SCR_tile_offset
  bne msl_draw_right_side_front
  jmp msl_load_new_tile_front
msl_draw_right_side_front:
  inc SCR_first_visible_tile
  ldy SCR_last_visible_tile
  SCR_draw_tile_right(1024, 1064, SCR_TILE_ROW_0)
  SCR_draw_tile_right(1104, 1144, SCR_TILE_ROW_1)
  SCR_draw_tile_right(1184, 1224, SCR_TILE_ROW_2)
  SCR_draw_tile_right(1264, 1304, SCR_TILE_ROW_3)
  SCR_draw_tile_right(1344, 1384, SCR_TILE_ROW_4)
  SCR_draw_tile_right(1424, 1464, SCR_TILE_ROW_5)
  SCR_draw_tile_right(1504, 1544, SCR_TILE_ROW_6) 
  SCR_draw_tile_right(1584, 1624, SCR_TILE_ROW_7)
  SCR_draw_tile_right(1664, 1704, SCR_TILE_ROW_8)
  SCR_draw_tile_right(1744, 1784, SCR_TILE_ROW_9)

  lda #0
  sta SCR_tile_offset
  jmp msl_loop_done
msl_load_new_tile_front:
  inc SCR_last_visible_tile
  ldy SCR_last_visible_tile
  SCR_draw_tile_left(1024, 1064, SCR_TILE_ROW_0)
  SCR_draw_tile_left(1104, 1144, SCR_TILE_ROW_1)
  SCR_draw_tile_left(1184, 1224, SCR_TILE_ROW_2)
  SCR_draw_tile_left(1264, 1304, SCR_TILE_ROW_3)
  SCR_draw_tile_left(1344, 1384, SCR_TILE_ROW_4)
  SCR_draw_tile_left(1424, 1464, SCR_TILE_ROW_5)
  SCR_draw_tile_left(1504, 1544, SCR_TILE_ROW_6) 
  SCR_draw_tile_left(1584, 1624, SCR_TILE_ROW_7)
  SCR_draw_tile_left(1664, 1704, SCR_TILE_ROW_8)
  SCR_draw_tile_left(1744, 1784, SCR_TILE_ROW_9)

  lda #1
  sta SCR_tile_offset
msl_loop_done:
  inc SCR_first_visible_column
  bne msl_done
  inc SCR_first_visible_column+1
msl_done:
  lda SCR_first_visible_column_pixels
  clc
  adc #8
  sta SCR_first_visible_column_pixels
  lda SCR_first_visible_column_pixels+1
  adc #0
  sta SCR_first_visible_column_pixels+1

  lda SCR_first_visible_column_pixels
  clc
  adc #<(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels
  lda SCR_first_visible_column_pixels+1
  adc #>(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels+1

  lda #1
  sta SCR_buffer_ready
  rts

SCR_move_color_right_upper:
  ldx #38
mcr_loop_upper:
  lda 55296, x
  sta 55297, x
  lda 55336, x
  sta 55337, x
  lda 55376, x
  sta 55377, x
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
  dex
  bmi mcr_loop_upper_done
  jmp mcr_loop_upper
mcr_loop_upper_done:
  ldx #0
  ldy SCR_first_visible_tile
  SCR_draw_color_tile_half(55296, 55336, SCR_TILE_ROW_0)
  SCR_draw_color_tile_half(55376, 55416, SCR_TILE_ROW_1)
  SCR_draw_color_tile_half(55456, 55496, SCR_TILE_ROW_2)
  SCR_draw_color_tile_half(55536, 55576, SCR_TILE_ROW_3)
  SCR_draw_color_tile_half(55616, 55656, SCR_TILE_ROW_4)
  rts

SCR_move_color_right_lower:
  ldx #38
mcr_loop:
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
  dex
  bmi mcr_loop_done
  jmp mcr_loop
mcr_loop_done:
  ldx #0
  ldy SCR_first_visible_tile
  SCR_draw_color_tile_half(55696, 55736, SCR_TILE_ROW_5)
  SCR_draw_color_tile_half(55776, 55816, SCR_TILE_ROW_6) 
  SCR_draw_color_tile_half(55856, 55896, SCR_TILE_ROW_7)
  SCR_draw_color_tile_half(55936, 55976, SCR_TILE_ROW_8)
  SCR_draw_color_tile_half(56016, 56056, SCR_TILE_ROW_9)
  rts

SCR_move_screen_right:
  lda #%00000010
  sta SCR_color_flag
  ldx #38
  lda SCR_buffer_flag
  beq msr_char_loop_f2b_loop
  jmp msr_char_loop_b2f_loop
msr_char_loop_f2b_loop:
  lda 1024, x
  sta 2049, x
  lda 1064, x
  sta 2089, x
  lda 1104, x
  sta 2129, x
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
  dex
  bmi msr_fill_left_side_back
  bpl msr_char_loop_f2b_loop
msr_fill_left_side_back:
  // shifted all the screen chars, now let's draw the new left column
  ldx #0
  lda SCR_tile_offset
  bne msr_draw_left_side_back
  jmp msr_load_new_tile_back
msr_draw_left_side_back:
  dec SCR_last_visible_tile
  ldy SCR_first_visible_tile
  SCR_draw_tile_left(2048, 2088, SCR_TILE_ROW_0)
  SCR_draw_tile_left(2128, 2168, SCR_TILE_ROW_1)
  SCR_draw_tile_left(2208, 2248, SCR_TILE_ROW_2)
  SCR_draw_tile_left(2288, 2328, SCR_TILE_ROW_3)
  SCR_draw_tile_left(2368, 2408, SCR_TILE_ROW_4)
  SCR_draw_tile_left(2448, 2488, SCR_TILE_ROW_5)
  SCR_draw_tile_left(2528, 2568, SCR_TILE_ROW_6)
  SCR_draw_tile_left(2608, 2648, SCR_TILE_ROW_7)
  SCR_draw_tile_left(2688, 2728, SCR_TILE_ROW_8)
  SCR_draw_tile_left(2768, 2808, SCR_TILE_ROW_9)

  lda #0
  sta SCR_tile_offset
  jmp msr_loop_done
msr_load_new_tile_back:
  dec SCR_first_visible_tile
  ldy SCR_first_visible_tile
  SCR_draw_tile_right(2048, 2088, SCR_TILE_ROW_0)
  SCR_draw_tile_right(2128, 2168, SCR_TILE_ROW_1)
  SCR_draw_tile_right(2208, 2248, SCR_TILE_ROW_2)
  SCR_draw_tile_right(2288, 2328, SCR_TILE_ROW_3)
  SCR_draw_tile_right(2368, 2408, SCR_TILE_ROW_4)
  SCR_draw_tile_right(2448, 2488, SCR_TILE_ROW_5)
  SCR_draw_tile_right(2528, 2568, SCR_TILE_ROW_6)
  SCR_draw_tile_right(2608, 2648, SCR_TILE_ROW_7)
  SCR_draw_tile_right(2688, 2728, SCR_TILE_ROW_8)
  SCR_draw_tile_right(2768, 2808, SCR_TILE_ROW_9)

  lda #1
  sta SCR_tile_offset
  jmp msr_loop_done
msr_char_loop_b2f_loop:
  lda 2048, x
  sta 1025, x
  lda 2088, x
  sta 1065, x
  lda 2128, x
  sta 1105, x
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
  dex
  bmi msr_fill_left_side_front
  jmp msr_char_loop_b2f_loop
msr_fill_left_side_front:
  // shifted all the screen chars, now let's draw the new left column
  ldx #0
  lda SCR_tile_offset
  bne msr_draw_left_side_front
  jmp msr_load_new_tile_front
msr_draw_left_side_front:
  dec SCR_last_visible_tile
  ldy SCR_first_visible_tile
  SCR_draw_tile_left(1024, 1064, SCR_TILE_ROW_0)
  SCR_draw_tile_left(1104, 1144, SCR_TILE_ROW_1)
  SCR_draw_tile_left(1184, 1224, SCR_TILE_ROW_2)
  SCR_draw_tile_left(1264, 1304, SCR_TILE_ROW_3)
  SCR_draw_tile_left(1344, 1384, SCR_TILE_ROW_4)
  SCR_draw_tile_left(1424, 1464, SCR_TILE_ROW_5)
  SCR_draw_tile_left(1504, 1544, SCR_TILE_ROW_6) 
  SCR_draw_tile_left(1584, 1624, SCR_TILE_ROW_7)
  SCR_draw_tile_left(1664, 1704, SCR_TILE_ROW_8)
  SCR_draw_tile_left(1744, 1784, SCR_TILE_ROW_9)

  lda #0
  sta SCR_tile_offset
  jmp msr_loop_done
msr_load_new_tile_front:
  dec SCR_first_visible_tile
  ldy SCR_first_visible_tile
  SCR_draw_tile_right(1024, 1064, SCR_TILE_ROW_0)
  SCR_draw_tile_right(1104, 1144, SCR_TILE_ROW_1)
  SCR_draw_tile_right(1184, 1224, SCR_TILE_ROW_2)
  SCR_draw_tile_right(1264, 1304, SCR_TILE_ROW_3)
  SCR_draw_tile_right(1344, 1384, SCR_TILE_ROW_4)
  SCR_draw_tile_right(1424, 1464, SCR_TILE_ROW_5)
  SCR_draw_tile_right(1504, 1544, SCR_TILE_ROW_6) 
  SCR_draw_tile_right(1584, 1624, SCR_TILE_ROW_7)
  SCR_draw_tile_right(1664, 1704, SCR_TILE_ROW_8)
  SCR_draw_tile_right(1744, 1784, SCR_TILE_ROW_9)

  lda #1
  sta SCR_tile_offset
msr_loop_done:
  lda SCR_first_visible_column
  sec
  sbc #1
  sta SCR_first_visible_column
  lda SCR_first_visible_column+1
  sbc #0
  sta SCR_first_visible_column+1

  lda SCR_first_visible_column_pixels
  sec
  sbc #8
  sta SCR_first_visible_column_pixels
  lda SCR_first_visible_column_pixels+1
  sbc #0
  sta SCR_first_visible_column_pixels+1

  lda SCR_first_visible_column_pixels
  clc
  adc #<(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels
  lda SCR_first_visible_column_pixels+1
  adc #>(scrwidth*8)
  sta SCR_first_column_beyond_screen_pixels+1
msr_done:
  lda #1
  sta SCR_buffer_ready
  rts




SCR_rowptrs_lo:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SCR_rowptrs_hi:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0