.var tiles_ul = $2000
.var tiles_ur = $2100
.var tiles_bl = $2200
.var tiles_br = $2300
.var level_tiles = $2400

gen_tiles:
  ldx #0
  ldy #0
test_tiles_loop:
  
  iny
  beq test_tiles_loop_done
test_tiles_loop_done:
  rts