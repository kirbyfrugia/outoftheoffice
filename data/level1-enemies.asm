init_level_enemies:
  lda #0
  sta enemies_count

  // add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 2, 7, 0, 10, 0)
  // add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 11, 15, 0, 6, 8)
  add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 16, 26, 0, 10, 0)
  add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 36, 41, 0, 10, 0)
  add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 50, 57, 0, 10, 0)
  // add_init_enemy(ENEMY_MOUSE_TYPE, ENEMY_MOUSE_WIDTH, ENEMY_MOUSE_HEIGHT, 73, 79, 0, 10, 0)

init_enemies_done:
  rts