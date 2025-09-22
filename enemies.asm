.const ENEMY_TILE_SIZE           = 16
.const ENEMY_TILE_CHAR_SIZE      = 8

// Enemy types
// 0 - mouse

.const ENEMY_MOUSE_WIDTH = 16
.const ENEMY_MOUSE_HEIGHT = 9

.const ENEMY_FLAG_DEAD         = %10000000
.const ENEMY_FLAG_DYING        = %01000000
.const ENEMY_FLAG_HDIRECTION   = %00100000
.const ENEMY_FLAG_VDIRECTION   = %00010000
.const ENEMY_FLAG_ONSCREEN     = %00001000

.const ENEMY_ANIMATION_FRAMES_DEATH = %00011111 

// stores the offset of the first animation frame
enemies_animations_left:
  .byte 3

// stores the offset of the first animation frame
enemies_animations_right:
  .byte 0

enemies_animations_death:
  .byte 6

enemies_collision_offsetx:
  .byte 2

enemies_collision_width:
  .byte 14

enemies_collision_offsety:
  .byte 3

enemies_collision_height:
  .byte 5


// enemies_rangex_min_lo:

// enemies_rangex_min_hi:

// enemies_rangex_max_lo:

// enemies_rangex_max_hi:

// enemies_posx_lo:

// enemies_posx_hi:

// enemies_posy:

// enemies_width:

// enemies_height:

// // See enemies.asm for flags
// enemies_flags:

// enemies_dead_animation_frames:

// // which sprite slot should be used for each enemy?
// // Let's try to keep it to 4 on screen at a time just for speed and
// //   to allow the other slots to be used
// // Also, the sprites should be sorted in order from left
// //   to right in the level so we won't end up in a situation
// //   where two sprites will try to use the same slot
// // .byte 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4
// enemies_sprite_slots:

// enemies_sprite_pos_offset:

// enemies_sprite_base_offset:
