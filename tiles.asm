.var tiles_ul = $4000
.var tiles_ur = $4100
.var tiles_ll = $4200
.var tiles_lr = $4300
.var level_tiles = $4400
.var TEST_MAP_WIDTH = 256


make_test_tiles:
  ldx #0
  ldy #0
mtt_loop:
  tya
  sta tiles_ul, x
  sta tiles_ur, x
  sta tiles_ll, x
  sta tiles_lr, x
  cpy #26
  bne mtt_nowrap
  ldy #0
mtt_nowrap:
  iny
  inx
  bne mtt_loop
  rts

make_test_map:
  ldx #0
  lda #0
mtm_loop: // fill the map with the empty tile (tile id zero)
  sta level_tiles+(TEST_MAP_WIDTH*0), x
  sta level_tiles+(TEST_MAP_WIDTH*1), x
  sta level_tiles+(TEST_MAP_WIDTH*2), x
  sta level_tiles+(TEST_MAP_WIDTH*3), x
  sta level_tiles+(TEST_MAP_WIDTH*4), x
  sta level_tiles+(TEST_MAP_WIDTH*5), x
  sta level_tiles+(TEST_MAP_WIDTH*6), x
  sta level_tiles+(TEST_MAP_WIDTH*7), x
  sta level_tiles+(TEST_MAP_WIDTH*8), x
  sta level_tiles+(TEST_MAP_WIDTH*9), x
  sta level_tiles+(TEST_MAP_WIDTH*10), x
  bne mtm_nowrap
mtm_nowrap:
  inx
  bne mtm_loop
  ldx #0
  lda #1
  sta level_tiles+(TEST_MAP_WIDTH*0), x
  lda #2
  sta level_tiles+(TEST_MAP_WIDTH*10), x
  
  ldx #10
  lda #3
  sta level_tiles+(TEST_MAP_WIDTH*0), x
  lda #4
  sta level_tiles+(TEST_MAP_WIDTH*10), x

  ldx #18
  lda #5
  sta level_tiles+(TEST_MAP_WIDTH*0), x
  lda #6
  sta level_tiles+(TEST_MAP_WIDTH*10), x
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


// X holds the tile index
// Y holds the screen column
.macro draw_tile(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda tiles_ul, x
  sta scr_row_upper, y
  lda tiles_ur, x
  sta scr_row_upper+1, y
  lda tiles_ll, x
  sta scr_row_lower, y
  lda tiles_lr, x
  sta scr_row_lower+1, y
  pla
  tax
}

// X holds the tile index
// Y holds the screen column
.macro draw_tile_left(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda tiles_ul, x
  sta scr_row_upper, y
  lda tiles_ll, x
  sta scr_row_lower, y
  pla
  tax
}

// X holds the tile index
// Y holds the screen column
.macro draw_tile_right(scr_row_upper, scr_row_lower, tile_row) {
  txa
  pha
  lda tile_row, x
  tax
  lda tiles_ur, x
  sta scr_row_upper+1, y
  lda tiles_lr, x
  sta scr_row_lower+1, y
  pla
  tax
}

draw_screen:
  ldx #0 // tile index
  ldy #0 // screen column
ds_loop:
  draw_tile(1144, 1184, level_tiles+(TEST_MAP_WIDTH*0))
  draw_tile(1224, 1264, level_tiles+(TEST_MAP_WIDTH*1))
  draw_tile(1304, 1344, level_tiles+(TEST_MAP_WIDTH*2))
  draw_tile(1384, 1424, level_tiles+(TEST_MAP_WIDTH*3)) 
  draw_tile(1464, 1504, level_tiles+(TEST_MAP_WIDTH*4))
  draw_tile(1544, 1584, level_tiles+(TEST_MAP_WIDTH*5))
  draw_tile(1624, 1664, level_tiles+(TEST_MAP_WIDTH*6))
  draw_tile(1704, 1744, level_tiles+(TEST_MAP_WIDTH*7))
  draw_tile(1784, 1824, level_tiles+(TEST_MAP_WIDTH*8))
  draw_tile(1864, 1904, level_tiles+(TEST_MAP_WIDTH*9))
  draw_tile(1944, 1984, level_tiles+(TEST_MAP_WIDTH*10))
  
ds_loop_end:
  inx
  cpx tile_column_end
  beq ds_done
  iny
  iny
  jmp ds_loop
ds_done:
  rts

init_screen:
  lda #0
  sta tile_column_start
  sta tile_offset
  lda #20
  sta tile_column_end

  rts

// Basic algorithm:
//   There are 20 tiles in each row unless we're scrolled
//   by half a tile, in which case there are 21 in each tile row.
//
//   Iterate over each tile in a row until we get to the first
//   nonzero tile. Then draw that tile. Keep drawing tiles
//   until we get to the first zero tile. Draw that tile.
//   Repeat until we've drawn all the tiles in the row.
//
//   If we're scrolled by half a tile, we need to draw an extra
//   tile at the beginning and end of the row.
//
//   psuedocode:
//   if we're scrolled by half a tile and the first tile is not zero,
//     draw the right side of the first tile.
//   
//   Iterate over the next 19 tiles. 
//   do first tile
//     if we're scrolled by half a tile, draw the first tile
//   while tile in row is not zero and :
//

.macro move_row_left(screen_row_upper, screen_row_lower, tile_row) {
  ldy #0 // screen column
  ldx tile_column_start
  lda tile_offset
  beq mrl_first_full
  lda tile_row, x
  sta prev_tile
  draw_tile_right(screen_row_upper, screen_row_lower, tile_row)
  inx
  iny
  bne mrl_loop
mrl_first_full:
  lda tile_row, x
  sta prev_tile
  draw_tile(screen_row_upper, screen_row_lower, tile_row)
  inx
  iny
  iny
mrl_loop:
  lda tile_row, x
  pha
  beq mrl_loop_zero
  draw_tile(screen_row_upper, screen_row_lower, tile_row)
  jmp mrl_loop_next
mrl_loop_zero:
  cmp prev_tile
  beq mrl_loop_next
  draw_tile(screen_row_upper, screen_row_lower, tile_row)
mrl_loop_next:
  pla
  sta prev_tile
  inx
  iny
  iny
  cpy #38
  bcc mrl_loop
  cpy #39
  bcc mrl_loop_done
  draw_tile_left(screen_row_upper, screen_row_lower, tile_row)
mrl_loop_done:
}

move_map_left:
  //inc tmp1
  lda tile_offset
  beq mml_set_offset
  lda #0
  sta tile_offset
  inc tile_column_start
  bne mml_move
mml_set_offset:
  lda #1
  sta tile_offset
mml_move:
  move_row_left(1144, 1184, level_tiles+(TEST_MAP_WIDTH*0))
  move_row_left(1224, 1264, level_tiles+(TEST_MAP_WIDTH*1))
  move_row_left(1304, 1344, level_tiles+(TEST_MAP_WIDTH*2))
  move_row_left(1384, 1424, level_tiles+(TEST_MAP_WIDTH*3)) 
  move_row_left(1464, 1504, level_tiles+(TEST_MAP_WIDTH*4))
  move_row_left(1544, 1584, level_tiles+(TEST_MAP_WIDTH*5))
  move_row_left(1624, 1664, level_tiles+(TEST_MAP_WIDTH*6))
  move_row_left(1704, 1744, level_tiles+(TEST_MAP_WIDTH*7))
  move_row_left(1784, 1824, level_tiles+(TEST_MAP_WIDTH*8))
  move_row_left(1864, 1904, level_tiles+(TEST_MAP_WIDTH*9))
  move_row_left(1944, 1984, level_tiles+(TEST_MAP_WIDTH*10))

mml_done:
  rts

move_map_right:
  rts

// draw_screen:
//   lda #<map_data
//   sta zpb0
//   lda #>map_data
//   sta zpb0

//   ldx #3
// draw_screen_row_loop:
//   draw_tile_row(1144, 1184, map_data+(MAP_WID*3))
//   rts

// TODO: move this to the zero page
tile_index_temp: .byte 0
screen_index_temp: .byte 0

tile_column_start: .byte 0
tile_column_end: .byte 0
tile_offset: .byte 0
prev_tile: .byte 0
curr_tile: .byte 0