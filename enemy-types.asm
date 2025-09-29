// This is the definition of enemy types and their properties

.const ENEMY_TILE_SIZE           = 16
.const ENEMY_TILE_CHAR_SIZE      = 8

// Enemy types
// 0 - mouse
// 1 - big spider
// 2 - small spider
// 3 - alternate mouse
// 4 - female worker

.const ENEMY_MOUSE_TYPE           = 0
.const ENEMY_MOUSE_WIDTH          = 16
.const ENEMY_MOUSE_HEIGHT         = 9

.const ENEMY_MOUSE2_TYPE          = 3
.const ENEMY_MOUSE2_WIDTH         = 15
.const ENEMY_MOUSE2_HEIGHT        = 12

.const ENEMY_BIG_SPIDER_TYPE      = 1
.const ENEMY_BIG_SPIDER_WIDTH     = 22
.const ENEMY_BIG_SPIDER_HEIGHT    = 12

.const ENEMY_SMALL_SPIDER_TYPE    = 2
.const ENEMY_SMALL_SPIDER_WIDTH   = 13
.const ENEMY_SMALL_SPIDER_HEIGHT  = 10

.const ENEMY_FEMALE_WORKER_TYPE   = 4
.const ENEMY_FEMALE_WORKER_WIDTH  = 12
.const ENEMY_FEMALE_WORKER_HEIGHT = 19+8 // bottom of chair is a screen character

.const ENEMY_FLAG_DEAD              = %10000000
.const ENEMY_FLAG_DYING             = %01000000
.const ENEMY_FLAG_HDIRECTION        = %00100000
.const ENEMY_FLAG_VDIRECTION        = %00010000
.const ENEMY_FLAG_ONSCREEN          = %00001000

.const ENEMY_CLASS_SIMPLE           = %10000000 // simple kill enemy type
.const ENEMY_CLASS_OBJECTIVE        = %01000000 // job objective type

.const ENEMY_ANIMATION_FRAMES_DEATH = %00011111 

// stores the offset of the first animation frame
enemies_animations_negative:
  .byte 3
  .byte 10
  .byte 17
  .byte 24
  .byte 28

// stores the offset of the first animation frame
enemies_animations_positive:
  .byte 0
  .byte 7
  .byte 14
  .byte 21
  .byte 28

enemies_animations_death:
  .byte 6
  .byte 13
  .byte 20
  .byte 27
  .byte 28

enemies_collision_offsetx:
  .byte 2
  .byte 4
  .byte 1
  .byte 1
  .byte 0

enemies_collision_width:
  .byte 14
  .byte 14
  .byte 11
  .byte 13
  .byte 12

enemies_collision_offsety:
  .byte 3
  .byte 2
  .byte 0
  .byte 5
  .byte 1

enemies_collision_height:
  .byte 5
  .byte 10
  .byte 9
  .byte 7
  .byte 18+8 // bottom of char is included

enemies_hspeed:
  .byte 1
  .byte 0
  .byte 0
  .byte 1
  .byte 0

enemies_vspeed:
  .byte 0
  .byte 1
  .byte 1
  .byte 0
  .byte 0

// flags

enemies_class:
  .byte ENEMY_CLASS_SIMPLE
  .byte ENEMY_CLASS_SIMPLE
  .byte ENEMY_CLASS_SIMPLE
  .byte ENEMY_CLASS_SIMPLE
  .byte ENEMY_CLASS_OBJECTIVE

