
// // Basic algorithm:
// //   There are 20 tiles in each row unless we're scrolled
// //   by half a tile, in which case there are 21 in each tile row.
// //
// //   Iterate over each tile in a row until we get to the first
// //   nonzero tile. Then draw that tile. Keep drawing tiles
// //   until we get to the first zero tile. Draw that tile.
// //   Repeat until we've drawn all the tiles in the row.
// //
// //   If we're scrolled by half a tile, we need to draw an extra
// //   tile at the beginning and end of the row.
// //
// //   psuedocode:
// //   if we're scrolled by half a tile and the first tile is not zero,
// //     draw the right side of the first tile.
// //   
// //   Iterate over the next 19 tiles. 
// //   do first tile
// //     if we're scrolled by half a tile, draw the first tile
// //   while tile in row is not zero and :
// //
// .macro move_row_left(screen_row_upper, screen_row_lower, tile_row) {
//   ldx tile_column_start
//   lda tile_row, x
//   beq mrl_await_non_zero
  

// mrl_await_non_zero:
// }

// // .macro move_row_left(screen_row_upper, screen_row_lower, tile_row) {
// //   ldy #0 // screen column
// //   ldx tile_column_start
// //   lda tile_offset
// //   beq mrl_first_full
// //   lda tile_row, x
// //   sta prev_tile
// //   draw_tile_right(screen_row_upper, screen_row_lower, tile_row)
// //   inx
// //   iny
// //   bne mrl_loop
// // mrl_first_full:
// //   lda tile_row, x
// //   sta prev_tile
// //   draw_tile(screen_row_upper, screen_row_lower, tile_row)
// //   inx
// //   iny
// //   iny
// // mrl_loop:
// //   lda tile_row, x
// //   pha
// //   beq mrl_loop_zero
// //   draw_tile(screen_row_upper, screen_row_lower, tile_row)
// //   jmp mrl_loop_next
// // mrl_loop_zero:
// //   cmp prev_tile
// //   beq mrl_loop_next
// //   draw_tile(screen_row_upper, screen_row_lower, tile_row)
// // mrl_loop_next:
// //   pla
// //   sta prev_tile
// //   inx
// //   iny
// //   iny
// //   cpy #38
// //   bcc mrl_loop
// //   cpy #39
// //   bcc mrl_loop_done
// //   draw_tile_left(screen_row_upper, screen_row_lower, tile_row)
// // mrl_loop_done:
// // }

// move_map_left:
//   //inc tmp1
//   lda tile_offset
//   beq mml_set_offset
//   lda #0
//   sta tile_offset
//   inc tile_column_start
//   bne mml_move
// mml_set_offset:
//   lda #1
//   sta tile_offset
// mml_move:
//   move_row_left(1144, 1184, level_tiles+(TEST_MAP_WIDTH*0))
//   move_row_left(1224, 1264, level_tiles+(TEST_MAP_WIDTH*1))
//   move_row_left(1304, 1344, level_tiles+(TEST_MAP_WIDTH*2))
//   move_row_left(1384, 1424, level_tiles+(TEST_MAP_WIDTH*3)) 
//   move_row_left(1464, 1504, level_tiles+(TEST_MAP_WIDTH*4))
//   move_row_left(1544, 1584, level_tiles+(TEST_MAP_WIDTH*5))
//   move_row_left(1624, 1664, level_tiles+(TEST_MAP_WIDTH*6))
//   move_row_left(1704, 1744, level_tiles+(TEST_MAP_WIDTH*7))
//   move_row_left(1784, 1824, level_tiles+(TEST_MAP_WIDTH*8))
//   move_row_left(1864, 1904, level_tiles+(TEST_MAP_WIDTH*9))
//   move_row_left(1944, 1984, level_tiles+(TEST_MAP_WIDTH*10))

// mml_done:
//   rts

// move_map_right:
//   rts





// SCR_scroll_left:
//   lda SCR_scroll_offset
//   clc
//   adc SCR_scrollx
//   cmp #8
//   bcs SCR_scroll_left_shift
//   sta SCR_scroll_offset
//   lda SCR_scroll_register
//   sec
//   sbc SCR_scrollx
//   sta SCR_scroll_register
//   jmp SCR_scroll_leftd
// SCR_scroll_left_shift:
//   sec
//   sbc #8
//   sta SCR_scroll_offset
//   lda SCR_scroll_register
//   sec
//   sbc SCR_scrollx
//   and #%00000111
//   sta SCR_scroll_register
//   jsr move_map_left
// SCR_scroll_left_no_shift:
// SCR_scroll_leftd:
//   lda $d016
//   and #%11110000
//   ora SCR_scroll_register
//   sta $d016
//   rts



