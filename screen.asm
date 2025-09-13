.const SCR_objects_ptr               = $43 // and $44
.const SCR_tmp_var0                  = $54 // and $55
.const SCR_scroll_in                 = $56
.const SCR_scroll_out                = $57
.const SCR_scroll_register           = $58
.const SCR_scroll_offset             = $59
.const SCR_scroll_left_amounts       = $80
.const SCR_scroll_left_amounts_pre   = $80 // matches the previous on purpose
.const SCR_scroll_left_amounts_post  = $81
.const SCR_scroll_right_amounts      = $82
.const SCR_scroll_right_amounts_pre  = $82 // matches the previous on purpose
.const SCR_scroll_right_amounts_post = $83
.const SCR_scroll_redraw_flag        = $84

.const SCR_first_visible_tile        = $85
.const SCR_last_visible_tile         = $86
.const SCR_tile_offset               = $87
.const SCR_buffer_flag               = $88 // which buffer
.const SCR_buffer_ready              = $89 // buffer ready to be swapped
.const SCR_direction                 = $8a // which direction to move screen or scroll after a scroll
.const SCR_color_flag                = $8b
.const SCR_tile_level_width          = $8c


.const SCR_first_visible_column_max          = $4b // and $4c
.const SCR_first_visible_column              = $4d // and $4e
.const SCR_first_visible_column_pixels       = $4f // and $50
.const SCR_first_column_beyond_screen_pixels = $51 // and $52

// Memory map
//   Addresses of tile rows:
//     $0020-$0035 - indices of tile rows
//   Front buffer:
//     $0400-$07e7 - video matrix 40x25
//     $07f8-$07ff - sprite data pointers
//   Back buffer:
//     $0800-$0be7 - video matrix 40x25
//     $0bf8-$0bff - sprite data pointers
//   Sprite data, Batch 1 - mostly the player sprite, max 15 sprites
//     $0bfe-$0bff - just used to store the prg load location, ignored
//     $0c00-$0fbf - sprite sheet
//     $0fc0-$0fcf - sprite attrib data
//   ROM CHARSET
//     $1000-$1fff - unusable
// TODO: move this to a different memory bank so we can have more sprites
//       could also just store sprites somewhere else and copy in when needed.
//   Sprite data, Batch 2, max 96 sprites (to use more would require different vic bank)
//     $1ffe-$1fff - just used to store the prg load location, ignored
//     $2000-$37ff - sprite sheet
//     $3780-$37fe - sprite attrib data
//   Level data
//     $37fe-$37ff - just used to store the prg load location, ignored
//     $3800-$3fff - character set, 2048 bytes
//     $4000-$40ff - character set attribs, (material - collision info), 256 bytes
//     $4100-$44ff - char tileset data (raw tiles), 1024 bytes
//     $4500-$45ff - char tileset attrib data (1 color per tile), 256 bytes
//     $4600-$46ff - char tileset tag data (tile collisions), 256 bytes
//     $4700-$50ff - map, max 2560 bytes
//   Scratch space
//     $5100-$60ff
//   Actual level data
//     $6100-$7fff
//   More level data, tile metadata
//     note: this uses a lot of memory, but it makes accessing the tiles faster/easier
//     $c000-c9ff  - tile metadata, left-hand of tile
//     $ca00-d3ff  - tile metadata, right-hand of tile
//   Game program
//     $8000-?
.var SCR_TILE_ROW_BASE       = $20
.var SCR_TILE_ROW_0          = $20
.var SCR_TILE_ROW_1          = $22
.var SCR_TILE_ROW_2          = $24
.var SCR_TILE_ROW_3          = $26
.var SCR_TILE_ROW_4          = $28
.var SCR_TILE_ROW_5          = $2a
.var SCR_TILE_ROW_6          = $2c
.var SCR_TILE_ROW_7          = $2e
.var SCR_TILE_ROW_8          = $30
.var SCR_TILE_ROW_9          = $32
.var SCR_TILE_ROW_CURR       = $34
.var SCR_TILE_ROW            = $36 // temp var, careful
.var SCR_TILE_COL            = $37 // temp var, careful
.var SCR_charset_prg         = $37fe
.var SCR_charset             = $3800
.var SCR_char_attribs        = $4000
.var SCR_raw_tiles           = $4100
.var SCR_tiles_ul            = $4100
.var SCR_tiles_ur            = $4200
.var SCR_tiles_ll            = $4300
.var SCR_tiles_lr            = $4400
.var SCR_char_tileset_attrib = $4500
.var SCR_char_tileset_tag    = $4600
.var SCR_level_tiles         = $4700
.var SCR_scratch             = $5100

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

SCR_draw_screen:
  ldy SCR_last_visible_tile
  ldx #38 // screen column
ds_loop:
  SCR_draw_tile(1024, 1064, SCR_TILE_ROW_0)
  SCR_draw_tile(1104, 1144, SCR_TILE_ROW_1)
  SCR_draw_tile(1184, 1224, SCR_TILE_ROW_2)
  SCR_draw_tile(1264, 1304, SCR_TILE_ROW_3)
  SCR_draw_tile(1344, 1384, SCR_TILE_ROW_4)
  SCR_draw_tile(1424, 1464, SCR_TILE_ROW_5)
  SCR_draw_tile(1504, 1544, SCR_TILE_ROW_6) 
  SCR_draw_tile(1584, 1624, SCR_TILE_ROW_7)
  SCR_draw_tile(1664, 1704, SCR_TILE_ROW_8)
  SCR_draw_tile(1744, 1784, SCR_TILE_ROW_9)
  
  SCR_draw_color_tile(55296, 55336, SCR_TILE_ROW_0)
  SCR_draw_color_tile(55376, 55416, SCR_TILE_ROW_1)
  SCR_draw_color_tile(55456, 55496, SCR_TILE_ROW_2)
  SCR_draw_color_tile(55536, 55576, SCR_TILE_ROW_3)
  SCR_draw_color_tile(55616, 55656, SCR_TILE_ROW_4)
  SCR_draw_color_tile(55696, 55736, SCR_TILE_ROW_5)
  SCR_draw_color_tile(55776, 55816, SCR_TILE_ROW_6) 
  SCR_draw_color_tile(55856, 55896, SCR_TILE_ROW_7)
  SCR_draw_color_tile(55936, 55976, SCR_TILE_ROW_8)
  SCR_draw_color_tile(56016, 56056, SCR_TILE_ROW_9)
  // bottom two rows
  lda #66
  sta 1824, x
  sta 1825, x
  sta 2848, x
  sta 2849, x
  lda #0
  sta 1864, x
  sta 1865, x
  sta 2888, x
  sta 2889, x
  lda #11
  sta 56096, x
  sta 56097, x
  sta 56136, x
  sta 56137, x
  sta 57120, x
  sta 57121, x
  sta 57160, x
  sta 57161, x
ds_loop_end:
  dey
  bmi ds_done
  dex
  dex
  jmp ds_loop
ds_done:
  rts

SCR_init_screen:
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