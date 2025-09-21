.const ENEMIES_COUNT = 6

enemies_type:
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0

// must be sorted by minx
.const enemy0_minx = ENEMY_TILE_SIZE*5   + ENEMY_TILE_CHAR_SIZE*0
.const enemy0_maxx = ENEMY_TILE_SIZE*16  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy0_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT
.const enemy1_minx = ENEMY_TILE_SIZE*11  + ENEMY_TILE_CHAR_SIZE*0
.const enemy1_maxx = ENEMY_TILE_SIZE*15  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy1_posy = ENEMY_TILE_SIZE*6   + ENEMY_TILE_CHAR_SIZE*1 - ENEMY_MOUSE_HEIGHT
.const enemy2_minx = ENEMY_TILE_SIZE*21  + ENEMY_TILE_CHAR_SIZE*0
.const enemy2_maxx = ENEMY_TILE_SIZE*26  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy2_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT
.const enemy3_minx = ENEMY_TILE_SIZE*36  + ENEMY_TILE_CHAR_SIZE*0
.const enemy3_maxx = ENEMY_TILE_SIZE*39  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy3_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT
.const enemy4_minx = ENEMY_TILE_SIZE*50  + ENEMY_TILE_CHAR_SIZE*0
.const enemy4_maxx = ENEMY_TILE_SIZE*54  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy4_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT
.const enemy5_minx = ENEMY_TILE_SIZE*73  + ENEMY_TILE_CHAR_SIZE*0
.const enemy5_maxx = ENEMY_TILE_SIZE*79  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_WIDTH
.const enemy5_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT

// rangex - how far left and right can the enemy travel, max is one greater than end of their range
//   min tile, min tile offset (0 for left of tile, 1 for right), max tile, max tile offset
// These must be sorted in order from furthest left to furthest right
enemies_rangex_min_lo:
  .byte <enemy0_minx
  .byte <enemy1_minx
  .byte <enemy2_minx
  .byte <enemy3_minx
  .byte <enemy4_minx
  .byte <enemy5_minx

enemies_rangex_min_hi:
  .byte >enemy0_minx
  .byte >enemy1_minx
  .byte >enemy2_minx
  .byte >enemy3_minx
  .byte >enemy4_minx
  .byte >enemy5_minx

enemies_rangex_max_lo:
  .byte <enemy0_maxx
  .byte <enemy1_maxx
  .byte <enemy2_maxx
  .byte <enemy3_maxx
  .byte <enemy4_maxx
  .byte <enemy5_maxx

enemies_rangex_max_hi:
  .byte >enemy0_maxx
  .byte >enemy1_maxx
  .byte >enemy2_maxx
  .byte >enemy3_maxx
  .byte >enemy4_maxx
  .byte >enemy5_maxx

// posx - actual position of enemy
enemies_posx_lo:
  .byte <enemy0_maxx
  .byte <enemy1_maxx
  .byte <enemy2_maxx
  .byte <enemy3_maxx
  .byte <enemy4_maxx
  .byte <enemy5_maxx

enemies_posx_hi:
  .byte >enemy0_maxx
  .byte >enemy1_maxx
  .byte >enemy2_maxx
  .byte >enemy3_maxx
  .byte >enemy4_maxx
  .byte >enemy5_maxx

enemies_posy:
  .byte enemy0_posy
  .byte enemy1_posy
  .byte enemy2_posy
  .byte enemy3_posy
  .byte enemy4_posy
  .byte enemy5_posy

enemies_width:
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH

enemies_height:
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT

// See enemies.asm for flags
enemies_flags:
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000

enemies_dead_animation_frames:
  .byte ENEMY_ANIMATION_FRAMES_DEATH
  .byte ENEMY_ANIMATION_FRAMES_DEATH
  .byte ENEMY_ANIMATION_FRAMES_DEATH
  .byte ENEMY_ANIMATION_FRAMES_DEATH
  .byte ENEMY_ANIMATION_FRAMES_DEATH
  .byte ENEMY_ANIMATION_FRAMES_DEATH

// which sprite slot should be used for each enemy?
// Let's try to keep it to 4 on screen at a time just for speed and
//   to allow the other slots to be used
// Also, the sprites should be sorted in order from left
//   to right in the level so we won't end up in a situation
//   where two sprites will try to use the same slot
// .byte 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4
enemies_sprite_slots:
  .byte %00000010
  .byte %00000100
  .byte %00001000
  .byte %00010000
  .byte %00100000
  .byte %01000000

enemies_sprite_pos_offset:
  .byte 2
  .byte 4
  .byte 6
  .byte 8
  .byte 10
  .byte 12

enemies_sprite_base_offset:
  .byte 1
  .byte 2
  .byte 3
  .byte 4
  .byte 5
  .byte 6
