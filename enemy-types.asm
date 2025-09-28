// This is the definition of enemy types and their properties

.const ENEMY_TILE_SIZE           = 16
.const ENEMY_TILE_CHAR_SIZE      = 8

// Enemy types
// 0 - mouse

.const ENEMY_MOUSE_TYPE    = 0
.const ENEMY_MOUSE_WIDTH   = 16
.const ENEMY_MOUSE_HEIGHT  = 9

.const ENEMY_SPIDER_TYPE   = 1
.const ENEMY_SPIDER_WIDTH  = 22
.const ENEMY_SPIDER_HEIGHT = 12

.const ENEMY_FLAG_DEAD         = %10000000
.const ENEMY_FLAG_DYING        = %01000000
.const ENEMY_FLAG_HDIRECTION   = %00100000
.const ENEMY_FLAG_VDIRECTION   = %00010000
.const ENEMY_FLAG_ONSCREEN     = %00001000

.const ENEMY_ANIMATION_FRAMES_DEATH = %00011111 

// stores the offset of the first animation frame
enemies_animations_negative:
  .byte 3
  .byte 10

// stores the offset of the first animation frame
enemies_animations_positive:
  .byte 0
  .byte 7

enemies_animations_death:
  .byte 6
  .byte 13

enemies_collision_offsetx:
  .byte 2
  .byte 4

enemies_collision_width:
  .byte 14
  .byte 14

enemies_collision_offsety:
  .byte 3
  .byte 2

enemies_collision_height:
  .byte 5
  .byte 10

enemies_hspeed:
  .byte 1
  .byte 0

enemies_vspeed:
  .byte 0
  .byte 1

