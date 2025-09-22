// Memory map
//   Addresses of tile rows:
//     $0020-$0035 - indices of tile rows
//   Front buffer:
//     $0400-$07e7 - video matrix 40x25
//     $07f8-$07ff - sprite data pointers
//   Back buffer:
//     $0800-$0be7 - video matrix 40x25
//     $0bf8-$0bff - sprite data pointers
//   Sprite data, Batch 1 - mostly the player sprite, max 15 sprites
//     $0bfe-$0bff - just used to store the prg load location, ignored
//     $0c00-$0fbf - sprite sheet
//     $0fc0-$0fcf - sprite attrib data
//   ROM CHARSET
//     $1000-$1fff - unusable
// TODO: move this to a different memory bank so we can have more sprites
//       could also just store sprites somewhere else and copy in when needed.
//   Sprite data, Batch 2, max 96 sprites (to use more would require different vic bank)
//     $1ffe-$1fff - just used to store the prg load location, ignored
//     $2000-$37ff - sprite sheet
//     $3780-$37fe - sprite attrib data
//   Level data
//     $37fe-$37ff - just used to store the prg load location, ignored
//     $3800-$3fff - character set, 2048 bytes
//     $4000-$40ff - character set attribs, (material - collision info), 256 bytes
//     $4100-$44ff - char tileset data (raw tiles), 1024 bytes
//     $4500-$45ff - char tileset attrib data (1 color per tile), 256 bytes
//     $4600-$46ff - char tileset tag data (tile collisions), 256 bytes
//     $4700-$50ff - tile map, max 2560 bytes (256 tiles, 10 rows)
//   Enemy data
//     $5100-$???? - dynamic size, could constrain if needed.

//   Scratch space
//     $7600-$7fff - 2560 bytes, used during initialization of tile map, free to use after
//   Game program
//     $8000-????  - dynamic size

.const zpb0                                  = $fb
.const zpb1                                  = $fc
.const zpb2                                  = $fd
.const zpb3                                  = $fe
.const zpb4                                  = $39
.const zpb5                                  = $3a
.const zpb6                                  = $3b
.const zpb7                                  = $3c
.const zpb8                                  = $3d
.const zpb9                                  = $3e

.var SCR_TILE_ROW_BASE       = $20
.var SCR_TILE_ROW_0          = $20
.var SCR_TILE_ROW_1          = $22
.var SCR_TILE_ROW_2          = $24
.var SCR_TILE_ROW_3          = $26
.var SCR_TILE_ROW_4          = $28
.var SCR_TILE_ROW_5          = $2a
.var SCR_TILE_ROW_6          = $2c
.var SCR_TILE_ROW_7          = $2e
.var SCR_TILE_ROW_8          = $30
.var SCR_TILE_ROW_9          = $32
.var current_tile_row        = $34
.var SCR_TILE_ROW            = $36 // temp var, careful
.var SCR_TILE_COL            = $37 // temp var, careful

// NOTE $39 to $3e are used above!!!


.const p1gy_coll                             = $3f // and $40
.const p1gx                                  = $41 // and $42
.const p1gx_new                              = $43 // and $44
.const p1gy_new                              = $45 // and $46
.const p1gx_offset                           = $47 // and $48
.const p1gy_offset                           = $49 // and $4a
.const p1gy                                  = $4b // and $4c
.const p1gx_coll                             = $4d // and $4e
.const p1gx_adder                            = $4f // and $50
.const p1gy_adder                            = $51 // and $52
.const collision_mask                        = $53
.const collision_tile_coords                 = $54 // for collision, used to determine which char of the tile is hit
.const collision_detected_major              = $55
.const collision_detected_minor              = $56
.const p1sx_old                              = $57 // and $58
.const p1sy_old                              = $59
.const p1sx                                  = $5a // and $5b
.const p1sy                                  = $5c

.const SCR_objects_ptr                       = $60 // and $61
.const SCR_first_visible_column_max          = $62 // and $63
.const SCR_first_visible_column              = $64 // and $65
.const SCR_first_visible_column_pixels       = $66 // and $67
.const SCR_first_column_beyond_screen_pixels = $68 // and $69
.const SCR_tmp_var0                          = $6a // and $6b
.const SCR_scroll_in                         = $6c
.const SCR_scroll_out                        = $6d
.const SCR_scroll_register                   = $6e
.const SCR_scroll_offset                     = $6f
.const SCR_scroll_left_amounts               = $80
.const SCR_scroll_left_amounts_pre           = $80 // matches the previous on purpose
.const SCR_scroll_left_amounts_post          = $81
.const SCR_scroll_right_amounts              = $82
.const SCR_scroll_right_amounts_pre          = $82 // matches the previous on purpose
.const SCR_scroll_right_amounts_post         = $83
.const SCR_scroll_redraw_flag                = $84
.const SCR_first_visible_tile                = $85
.const SCR_last_visible_tile                 = $86
.const SCR_tile_offset                       = $87
.const SCR_buffer_flag                       = $88 // which buffer
.const SCR_buffer_ready                      = $89 // buffer ready to be swapped
.const SCR_direction                         = $8a // which direction to move screen or scroll after a scroll
.const SCR_color_flag                        = $8b
.const SCR_tile_level_width                  = $8c


.var SCR_charset_prg         = $37fe
.var SCR_charset             = $3800
.var SCR_char_attribs        = $4000
.var SCR_raw_tiles           = $4100
.var SCR_tiles_ul            = $4100
.var SCR_tiles_ur            = $4200
.var SCR_tiles_ll            = $4300
.var SCR_tiles_lr            = $4400
.var SCR_char_tileset_attrib = $4500
.var SCR_char_tileset_tag    = $4600
.var SCR_level_tiles         = $4700
.var ENEMY_DATA              = $5100
.var SCRATCH_SPACE           = $7600