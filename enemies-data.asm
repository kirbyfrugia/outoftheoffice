.segment EnemyData [start=$5100]

.const MAX_ENEMIES           = 128
.var ASSEMBLER_ENEMIES_COUNT = 0

enemies_data_start:

enemies_type:
  .fill MAX_ENEMIES, 0

enemies_rangex_min_lo:
  .fill MAX_ENEMIES, 0

enemies_rangex_min_hi:
  .fill MAX_ENEMIES, 0

enemies_rangex_max_lo:
  .fill MAX_ENEMIES, 0

enemies_rangex_max_hi:
  .fill MAX_ENEMIES, 0

enemies_posx_lo:
  .fill MAX_ENEMIES, 0

enemies_posx_hi:
  .fill MAX_ENEMIES, 0

enemies_posy:
  .fill MAX_ENEMIES, 0

enemies_width:
  .fill MAX_ENEMIES, 0

enemies_height:
  .fill MAX_ENEMIES, 0

// See enemies.asm for flags
enemies_flags:
  .fill MAX_ENEMIES, 0

enemies_dead_animation_frames:
  .fill MAX_ENEMIES, 0

// which sprite slot should be used for each enemy?
// Let's try to keep it to 4 on screen at a time just for speed and
//   to allow the other slots to be used
// Also, the sprites should be sorted in order from left
//   to right in the level so we won't end up in a situation
//   where two sprites will try to use the same slot
// .byte 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4
enemies_sprite_slots:
  .fill MAX_ENEMIES, 0

enemies_sprite_pos_offset:
  .fill MAX_ENEMIES, 0

enemies_sprite_base_offset:
  .fill MAX_ENEMIES, 0

enemies_data_end:

.macro add_init_enemy(enemy_type, width, height, rangex_min, rangex_max, posx_offset,posy, posy_offset) {
  ldx enemies_count

  lda #enemy_type
  sta enemies_type, x

// .const enemy0_minx = ENEMY_TILE_SIZE*5   + ENEMY_TILE_CHAR_SIZE*0
// .const enemy0_maxx = ENEMY_TILE_SIZE*16  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
// .const enemy0_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT


  lda #<(ENEMY_TILE_SIZE*rangex_min+posx_offset)
  sta enemies_rangex_min_lo, x
  sta enemies_posx_lo, x
  lda #>(ENEMY_TILE_SIZE*rangex_min+posx_offset)
  sta enemies_rangex_min_hi, x
  sta enemies_posx_hi, x

  lda #<(ENEMY_TILE_SIZE*rangex_max+posx_offset-width)
  sta enemies_rangex_max_lo, x
  lda #>(ENEMY_TILE_SIZE*rangex_max+posx_offset-width)
  sta enemies_rangex_max_hi, x

  lda #<(ENEMY_TILE_SIZE*posy+posy_offset-height)
  sta enemies_posy, x

  lda #width
  sta enemies_width, x

  lda #height
  sta enemies_height, x

  lda #%00000000
  sta enemies_flags, x

  lda #ENEMY_ANIMATION_FRAMES_DEATH
  sta enemies_dead_animation_frames, x

  .var enemy_index = ASSEMBLER_ENEMIES_COUNT

  .var sprite_base = mod(enemy_index, 7)+1
  .var sprite_pos_offset = sprite_base * 2
  .var sprite_slot = pow(2, sprite_base)

  lda #sprite_base
  sta enemies_sprite_base_offset, x

  lda #sprite_pos_offset
  sta enemies_sprite_pos_offset, x

  lda #sprite_slot
  sta enemies_sprite_slots, x

  .print "Added enemy number: "+enemy_index+","+sprite_slot+","+sprite_base+","+sprite_pos_offset

  .eval ASSEMBLER_ENEMIES_COUNT = ASSEMBLER_ENEMIES_COUNT + 1

  inx
  stx enemies_count

}

enemies_count:
  .byte 0
