// In the future, this file will be generated by a level editor.
//
// A level:
//   - Is made up of 2 to N vscreens
//   - Must have fewer than 256 unique object designs
//
// A screen:
//   - Is 38 characters wide, 23 characters tall
//
// An object:
//   - 
// object_data 
//   - character data for the object

// format:
//   globalxlo              - global horizontal position of the object (num chars from far left of level)
//   globalxhi
//   y                      - vertical position
//   object_data_ptr_lo     - pointer to the char data for the object
//   object_data_ptr_hi
//   metadata               - collision and color data for the object
//   onscreenx              - x position of the object on screen, 255 if not on screen
//   first_idx              - first index of object data visible on screen (e.g. 2 if object starts 2 chars left of screen)
LVL_objects:
  .byte $08, $00, $02, <LVL_object_data_0, >LVL_object_data_0, %00000001, $00, $00
LVL_objects_end:

// object
// format:
//   width, height, char array
LVL_object_data_0:
  .byte $01,$01,$01
  .byte $01,$01,$01
