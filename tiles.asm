// .var tiles_ul = $2000
// .var tiles_ur = $2100
// .var tiles_bl = $2200
// .var tiles_br = $2300
// .var level_tiles = $2400

.macro draw_tile_row(scr_row_upper, scr_row_lower, map_data_tile_row) {
  ldx #20
draw_tile_row_loop:

  dex
  bne draw_tile_row_loop
}

draw_screen:
  lda #<map_data
  sta zpb0
  lda #>map_data
  sta zpb0

  ldx #3
draw_screen_row_loop:
  draw_tile_row(1144, 1184, map_data+(MAP_WID*3))
  rts