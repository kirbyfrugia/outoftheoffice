.const ENEMY_TILE_SIZE           = 16
.const ENEMY_TILE_CHAR_SIZE      = 8

.const ENEMY_NUM_SHAKEOFF_TAPS    = 4
.const ENEMY_NUM_SHAKEOFF_RELEASE = 4

.const ENEMY_KILLBOX_HEIGHT       = 2

// Enemy types
// 0 - mouse

.const ENEMY_MOUSE_WIDTH = 16
.const ENEMY_MOUSE_HEIGHT = 9

// stores the offset of the first animation frame
enemies_animations_left:
  .byte 3

// stores the offset of the first animation frame
enemies_animations_right:
  .byte 0

enemies_killbox_offsetx:
  .byte 2

enemies_killbox_width:
  .byte 14

enemies_killbox_offsety:
  .byte 3

enemies_killbox_height:
  .byte 2
