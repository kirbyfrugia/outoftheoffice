.var ENG_tmp_var0              = $54
.var ENG_scrollx               = $56
.var ENG_scroll_register       = $57
.var ENG_scroll_offset         = $58
.var ENG_objects_ptr           = $43 // and $44

// How scrolling works:
//   You pass in the amount of pixels to scroll.
//   Uses the hardware register to scroll that many pixels
//   If, during the scrolling, the scroll register maxes out,
//     then it triggers a copy of characters one character over
//     to the left or right depending on the direction of the scroll
//   It will then continue scrolling pixel by pixel until it has scrolled
//     the amount requested or reached the end or beginning of the level.

// affects A,X,Y
// inputs:
//   ENG_scrollx - the amount to scroll
// outputs:
//   ENG_scrollx - the amount actually scrolled
// TODO: buggy, also doesn't currently handle end of the level.
scrolll:
  ldx ENG_scrollx
  lda #0
  sta ENG_scrollx
  cpx #0
  beq sld
sll:
  lda ENG_scroll_offset
  clc
  adc #1
  cmp #8
  beq slredraw // scroll register at max, so move chars on screen
  sta ENG_scroll_offset
  dec ENG_scroll_register
  lda $d016
  and #%11110000
  ora ENG_scroll_register
  sta $d016
  jmp slln
slredraw:  
// TODO: uncomment this. Figure out how to do end
  lda ENG_first_x+1
  cmp ENG_max_column0+1
  bcc slredrawok
  lda ENG_first_x
  cmp ENG_max_column0
  bcc slredrawok
  bcs sld
slredrawok:
  lda #0
  sta ENG_scroll_offset
  lda #%00000111
  sta ENG_scroll_register
  lda $d016
  ora #%00000111
  sta $d016

  stx ENG_tmp_var0
  jsr shift_screen_left
  //brk
  //jsr mvmlt
  ldx ENG_tmp_var0
slln:
  inc ENG_scrollx
  dex
  bne sll
sld:
  rts

// affects A,X,Y
// inputs:
//   ENG_scrollx - the amount to scroll
// outputs:
//   ENG_scrollx - the amount actually scrolled
scrollr:
  ldx ENG_scrollx
  lda #0
  sta ENG_scrollx
  cpx #0
  beq sld
srl:
  lda ENG_scroll_offset
  sec
  sbc #1
  bmi srredraw
  sta ENG_scroll_offset
  inc ENG_scroll_register
  lda $d016
  and #%11110000
  ora ENG_scroll_register
  sta $d016
  jmp srln
srredraw:  
  lda ENG_first_x
  bne srredrawok
  lda ENG_first_x+1
  bne srredrawok
  beq srd
srredrawok:
  lda #7
  sta ENG_scroll_offset
  lda #%00000000
  sta ENG_scroll_register
  lda $d016
  and #%11111000
  sta $d016

  stx ENG_tmp_var0
  jsr shift_screen_right
  ldx ENG_tmp_var0
srln:
  inc ENG_scrollx
  dex
  bne srl
srd:
  rts

ENG_max_column0:    .byte 0,0
ENG_first_x:        .byte 0,0
ENG_last_x:         .byte 0,0
ENG_visible_obj:    .byte 0