.const enemies_count = 2

// Enemy indices
// 0 - mouse 1
// 1 - mouse 2

enemies_sprite_index:
  .byte 8
  .byte 8

enemies_minx_lo:
  .byte <(8*5)
  .byte <(8*11)

enemies_minx_hi:
  .byte >(8*0)
  .byte >(8*0)

enemies_maxx_lo:
  .byte <(8*15)
  .byte <(8*14)

enemies_maxx_hi:
  .byte >(8*0)
  .byte >(8*0)

enemies_posx_lo:
  .byte <(8*5)
  .byte <(8*11)

enemies_posx_hi:
  .byte >(8*0)
  .byte >(8*0)

enemies_posy:
  .byte 160
  .byte 104