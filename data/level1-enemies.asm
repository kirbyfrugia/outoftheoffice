init_level_enemies:
  lda #0
  sta enemies_count

  add_init_enemy(ENEMY_MOUSE_TYPE,  ENEMY_MOUSE_WIDTH,  ENEMY_MOUSE_HEIGHT,  11, 0, 25, 0, 10, 0, 10, 0)
  add_init_enemy(ENEMY_MOUSE_TYPE,  ENEMY_MOUSE_WIDTH,  ENEMY_MOUSE_HEIGHT,  28, 0, 41, 0, 10, 0, 10, 0)
  add_init_enemy(ENEMY_SPIDER_TYPE, ENEMY_SPIDER_WIDTH, ENEMY_SPIDER_HEIGHT, 38, 0, 38, ENEMY_SPIDER_WIDTH/2+8, 1,  0, 6,  0)
  add_init_enemy(ENEMY_MOUSE_TYPE,  ENEMY_MOUSE_WIDTH,  ENEMY_MOUSE_HEIGHT,  44, 0, 51, 0, 10, 0, 10, 0)
  

init_enemies_done:
  rts