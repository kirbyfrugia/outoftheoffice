.var tiles_ul = $2000
.var tiles_ur = $2100
.var tiles_ll = $2200
.var tiles_lr = $2300
.var level_tiles = $2400
.var TEST_MAP_WIDTH = 256


make_test_tiles:
  ldx #0
  ldy #1
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
  ldx #0 // column
  ldy #0 // tile
mtm_loop:
  tya
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
  sta level_tiles+(TEST_MAP_WIDTH*11), x

  iny
  cpy #26
  bne mtm_nowrap
  ldy #0
mtm_nowrap:
  inx
  bne mtm_loop
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


.macro draw_tile(scr_row_upper, scr_row_lower, tile_row) {
  lda tiles_ul, x
  sta scr_row_upper, y
  lda tiles_ur, x
  sta scr_row_upper+1, y
  lda tiles_ll, x
  sta scr_row_lower, y
  lda tiles_lr, x
  sta scr_row_lower+1, y
}

draw_screen:
  ldx #0 // tile index
  ldy #0 // screen column
  stx tile_index_temp
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
  cpx #20
  beq ds_done
  iny
  iny
  jmp ds_loop
ds_done:
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