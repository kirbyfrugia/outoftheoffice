.const ENEMY_STRUCT_OFFSET_ANIM0 = 0
.const ENEMY_STRUCT_OFFSET_ANIM1 = 1
.const ENEMY_STRUCT_OFFSET_ANIM2 = 2



.const enemies_count = 2
// Enemy instances
// 0 - mouse 1
// 1 - mouse 2

enemies_type:
  .byte 0
  .byte 0

.const enemy0_minx = ENEMY_TILE_SIZE*5   + ENEMY_TILE_CHAR_SIZE*0
.const enemy0_maxx = ENEMY_TILE_SIZE*16  + ENEMY_TILE_CHAR_SIZE*0
.const enemy0_posy = ENEMY_TILE_SIZE*10  + ENEMY_TILE_CHAR_SIZE*0 - ENEMY_MOUSE_HEIGHT
.const enemy1_minx = ENEMY_TILE_SIZE*11  + ENEMY_TILE_CHAR_SIZE*0
.const enemy1_maxx = ENEMY_TILE_SIZE*15  + ENEMY_TILE_CHAR_SIZE*0
.const enemy1_posy = ENEMY_TILE_SIZE*6   + ENEMY_TILE_CHAR_SIZE*1 - ENEMY_MOUSE_HEIGHT
// rangex - how far left and right can the enemy travel, max is one greater than end of their range
//   min tile, min tile offset (0 for left of tile, 1 for right), max tile, max tile offset
enemies_rangex:
  .byte <enemy0_minx, >enemy0_minx, <enemy0_maxx, >enemy0_maxx
  .byte <enemy1_minx, >enemy1_minx, <enemy1_maxx, >enemy1_maxx

// posx - actual position of enemy
enemies_posx_lo:
  .byte <enemy0_minx
  .byte <enemy1_minx

enemies_posx_hi:
  .byte >enemy0_minx
  .byte >enemy1_minx

enemies_posy:
  .byte enemy0_posy
  .byte enemy1_posy

enemies_width:
  .byte ENEMY_MOUSE_WIDTH
  .byte ENEMY_MOUSE_WIDTH

enemies_height:
  .byte ENEMY_MOUSE_HEIGHT
  .byte ENEMY_MOUSE_HEIGHT

// flags
//   Bit 2: alive
//   Bit 1: direction, 0 = left, 1 = right
//   Bit 0: onscreen
enemies_flags:
  .byte %00000000
  .byte %00000000

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
  