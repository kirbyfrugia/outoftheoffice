#import "data/level1.asm"

.disk [filename="office.d64", name="OFFICE", id="O1" ] {
  [name="OFFICE", type="prg", segments="Office"],
  [name="LEVEL1", type="prg", segments="level1"]
}

.segment Office [outPrg="office.prg", start=$8000]
//.var hvzero    = 127
//.var maxhvl    = 88
//.var maxhvr    = 166
//
//.var vvzero    = 127
//.var maxvvu    = 93
//.var maxvvd    = 161

.var hvzero    = 127
.var maxhvl    = 92
.var maxhvr    = 162

.var vvzero    = 127
.var maxvvu    = 100
.var maxvvd    = 154

  jmp init

#import "data.asm"
#import "const.asm"
#import "utils.asm"
#import "level.asm"
#import "screen.asm"

init:
  // switch out basic
  lda $01
  and #%11111110
  sta $01

  lda #0
  sta ptime
  sta ptime+1
  sta ptime+2
  sta etime
  sta etime+1
  sta etime+2
  sta time
  sta time+1
  sta time+2
  sta ebl
  sta ebr
  sta ebu
  sta ebd
  sta ebp
  sta p1hva
  sta p1hva+1
  sta p1vva
  sta p1vva+1
  sta p1gx+1
  sta p1lx+1

  lda #hvzero
  sta p1hvi
  sta p1vvi

  lda #vvzero
  sta p1vvi
  sta p1vvi

  lda #0
  sta p1gx+1

  lda #8
  sta p1gx
  clc
  rol p1gx
  rol p1gx+1
  clc
  rol p1gx
  rol p1gx+1
  clc
  rol p1gx
  rol p1gx+1
  clc
  rol p1gx
  rol p1gx+1

  lda #176
  sta p1gy
  clc
  rol p1gy
  rol p1gy+1
  clc
  rol p1gy
  rol p1gy+1
  clc
  rol p1gy
  rol p1gy+1

  lda #0
  sta frame
 
  jsr initui
  jsr initsys
  jsr SCR_loadmap
  jsr loadmap
  // jsr redraw
  jsr initspr

  lda #0
  sta SCR_column_first_visible
  sta SCR_column_first_visible+1

  // TODO: fix this
  // 256 tiles * 16 bits per tile = 4096 = $1000
  // lda #$00
  // sec
  // sbc #scrwidth
  // sta SCR_column_first_visible_max
  // lda #$10
  // sbc #$00
  // sta SCR_column_first_visible_max+1

  // TODO: temp, remove
  // should be 37 less than maxp1gx
  lda #21
  sta SCR_column_first_visible_max
  lda #0
  sta SCR_column_first_visible_max+1


  //jsr SCR_make_test_tiles
  //jsr SCR_make_test_map
  jsr SCR_init_screen
  jsr SCR_draw_screen

loop:
  lda $d012
  //cmp #$fa
  cmp #13 // https://www.zimmers.net/cbmpics/cbm/c64/vic-ii.txt
  bne loop

  // use odd/even frames since the buffer flip may be faster
  // than the raster blank area
  lda frame
  eor #%00000001
  sta frame
  beq even_frame
  bne odd_frame
even_frame:
  lda SCR_buffer_ready // ignore input if we need to redraw
  bne loop
  lda #%00000000
  sta SCR_color_flag
  lda $dc00
  jsr injs
  jsr updp1hv
  jsr updp1vv
  jsr updp1p
  //jsr log
  lda SCR_buffer_ready // need to redraw due to wrapping scroll register
  bne loop
  SCR_update_scroll_register() // only scroll if we didn't redraw
  jmp loop
odd_frame:
  lda SCR_buffer_ready
  bne swap_buffer
  // TODO: we have time here to do other stuff...
  beq loop // scroll register didn't wrap
swap_buffer:
  lda #0
  sta SCR_buffer_ready
  lda SCR_buffer_flag
  beq loop_swap_to_back
  lda $d018
  and #%00001111
  ora #%00010000 // screen location 1024, $0400
  sta $d018
  lda #0
  sta SCR_buffer_flag
  SCR_update_scroll_register()
  jmp move_color
loop_swap_to_back:
  lda $d018
  and #%00001111
  ora #%00100000 // screen location 2048, $0800
  sta $d018
  lda #1
  sta SCR_buffer_flag
  SCR_update_scroll_register()
move_color:
  lda SCR_color_flag
  beq swap_buffer
  cmp #%00000001
  beq swap_color_left
  jsr SCR_move_color_right
  jmp loop
swap_color_left:
  jsr SCR_move_color_left
  jmp loop

cls:
  ldy #0
clsl:
  lda #1
  sta $d800,y
  sta $d800+$0100,y
  sta $d800+$0200,y
  sta $d800+$0300,y
//  lda #252
  lda #32
  sta $0400,y
  sta $0400+$0100,y
  sta $0400+$0200,y
  sta $0400+$0300,y
  sta $0800,y
  sta $0800+$0100,y
  sta $0800+$0200,y
  sta $0800+$0300,y
  iny
  bne clsl
  rts

initsys:
  // turn on multiclr char mode
  // lda $d016
  // ora #%00010000
  // sta $d016

  // use our in-memory charset
  lda $d018
  and #%11110000
  ora #%00001000 // $2000-27ff
  sta $d018

  lda #15
  sta $d021

  lda #0
  sta $d020

  rts

initspr:
  ldx #63
copyspr:
  lda p1spr, x
  sta $0c00, x
  dex
  bpl copyspr

  // set sprite multi colors
  lda #sprmc0
  sta $d025
  lda #sprmc1
  sta $d026

  // sprite pointers
  // location = (bank * 16384)+(sprptr*64)
  //          = (0*16384)+(48*64)=$0c00
  ldx #48 
  stx $07f8 // front buffer
  stx $0bf8 // back buffer

  lda #%00000001
  sta $d01c

  lda #%00000001
  sta $d015 //spr enable

  lda #$0a
  sta $d027 //spr 0 clr
  //sta $d028 //spr 1 clr
  //sta $d029 //spr 2 clr

  lda #128
  sta $d000 //spr0x
  //lda #16
  //sta $d002 //spr1x
  //sta $d004 //spr2x
  lda #%00000000
  sta $d010 //spr msb

  lda #218
  sta $d001 //spr0y
  //lda #58
  //sta $d003 //spr1y
  //lda #106
  //sta $d005 //spr2y

  rts

initui:
  jsr cls
  rts


loadmap:
  // TODO: this is where you set how far the player can go right, fix with real
  // 256 tiles * 2 columns per tile - player width (just say 2 columns) = 510 = $01fe
  // lda #$fe
  // sta maxp1gx
  // lda #$01
  // sta maxp1gx+1

  lda #58
  sta maxp1gx
  lda #$00
  sta maxp1gx+1

  // Shift 3 times to go from column count to pixels and then
  // shift 4 more to the left to account for the fractional portion
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  lda maxp1gx
  and #%10000000
  sta maxp1gx

  lda #(200-p1height-16)
//  lda #164
  sta maxp1gy
  lda #0
  sta maxp1gy+1

  rol maxp1gy
  rol maxp1gy+1
  rol maxp1gy
  rol maxp1gy+1
  rol maxp1gy
  rol maxp1gy+1
  lda maxp1gy
  and #%11111000
  sta maxp1gy

  rts


// todo dont assemble for release
log:
  lda #$00
  sta zpb0
  lda #$04
  sta zpb1

  ldy #1

  lda p1gx+1
  jsr loghexit
  iny
  lda p1gx
  jsr loghexit

  iny
  iny
  lda p1lx+1
  jsr loghexit
  iny
  lda p1lx
  jsr loghexit

  iny
  iny
  lda p1sx
  jsr loghexit

  iny
  iny
  lda p1hva+1
  jsr loghexit
  iny
  lda p1hva
  jsr loghexit

  iny
  iny
  lda SCR_column_first_visible+1
  jsr loghexit
  iny
  lda SCR_column_first_visible
  jsr loghexit
  iny
  lda #43
  sta (zpb0),y
  iny
  lda SCR_scroll_offset
  jsr loghexit

  iny
  iny
  lda SCR_scroll_register
  jsr loghexit

  iny
  iny
  lda SCR_scroll_in
  jsr loghexit
  iny
  iny
  lda SCR_scroll_out
  jsr loghexit

  // next row
  lda #$28
  sta zpb0
  lda #$04
  sta zpb1

  ldy #1

  lda p1gy+1
  jsr loghexit
  iny
  lda p1gy
  jsr loghexit

  iny
  iny
  iny
  iny
  lda p1ly
  jsr loghexit

  iny
  iny
  lda p1sy
  jsr loghexit

  iny
  iny
  lda p1vva+1
  jsr loghexit
  iny
  lda p1vva
  jsr loghexit

  iny
  iny
  lda collisions
  jsr loghexit

  iny
  iny
  lda tmp0
  jsr loghexit
  iny
  iny
  lda tmp1
  jsr loghexit

  iny
  iny
  lda SCR_tile_first_visible
  jsr loghexit
  iny
  lda SCR_tile_offset
  jsr loghexit
  iny
  lda SCR_tile_last_visible
  jsr loghexit

  // next row
  lda #$50
  sta zpb0
  lda #$04
  sta zpb1


  rts

// // in its own subroutine just
// // so we can time it
// redraw:
//   jsr gettime
//   lda time
//   sta ptime
//   lda time+1
//   sta ptime+1
//   lda time+2
//   sta ptime+2

//   //jsr drawscrn
//   jsr gettime

//   lda time
//   sec
//   sbc ptime
//   sta etime
//   lda time+1
//   sbc ptime+1
//   sta etime+1
//   lda time+2
//   sbc ptime+2
//   sta etime+2
//   rts


// How player velocity and positioning works.
// Velocity
//   There are two velocities: indexed velocity and actual velocity.
//     indexed velocity is a value from 0 to 255, unsigned.
//       0 is moving top speed to the left, 255 is top to the right, 127 is zero speed.
//     actual velocity is a signed value calculated by subtracting 127 from the indexed velocity.
//       the actual velocity is used when updating the player's position.
//   Player input determines target indexed velocity, which is either 0,127, or 255.
// Acceleration
//   If the player is moving one direction and is changing directions, then accel/decel
//     rate is higher.
// Position 
//   Player position is calculated by adding the current position to the actual velocity.
//     Global position is a 16 bit number stored in p1gx/+1.
// The 4 least significant bits of the actual velocity and position are fractional
//   and are truncated when updating the sprite's actual position on the screen.
//   This allows smoother and smaller movement, acceleration, etc.
// Key variables:
//   p1hvi - horiz vel,indexed
//   p1hva - horiz vel,actual
//   p1gx  - global xpos
//   p1lx  - local xpos (relative to column at far left of screen), minus fractional portion
//   p1sx  - screen xpos (screen char coords)
//           pre-collision it holds the position from 0..39,0..24
//           post-collision it holds the sprite position offset by #31,#50 (minus border)
//   p1vvi - vert vel,indexed
//   p1vva - vert vel,actual
//   p1gy  - global ypos
//   p1ly  - local ypos
//   p1hvt - horiz target vel
//   p1vvt - vert target vel
//   maxhvl - max velocity when moving left
//   maxhvr - max velocity when moving right

updp1hv:
  lda ebl
  and #%00000001
  beq updp1hvl
  lda ebr
  and #%00000001
  beq updp1hvr
  lda #hvzero
  sta p1hvt
  bne updp1htvd
updp1hvl:
  lda #maxhvl
  sta p1hvt
  bne updp1htvd
updp1hvr:
  lda #maxhvr
  sta p1hvt
updp1htvd:
  lda p1hvi
  cmp p1hvt
  beq updp1hvd
  bcc updp1haccel
  cmp #(hvzero+2)
  bcs updp1hdecel2
  dec p1hvi
  bne updp1hvd
updp1hdecel2:
  sec
  sbc #2
  sta p1hvi
  bne updp1hvd  
updp1haccel:
  cmp #(hvzero-1)
  bcc updp1haccel2
  inc p1hvi
  bne updp1hvd
updp1haccel2:
  clc
  adc #2
  sta p1hvi
updp1hvd:
  lda p1hvi
  sec
  sbc #hvzero
  sta p1hva
  lda #0
  sbc #0
  sta p1hva+1
  rts

updp1vv:
  // only jump on new button presses
  lda ebp
  and #%00000011
  cmp #%00000010
  beq updp1vvup
  lda ebd
  and #%00000001
  beq updp1vvdown
  lda #maxvvd
  sta p1vvt
  bne updp1vtvd
updp1vvup:
  // if not on the ground, ignore
  lda p1gy+1
  cmp maxp1gy+1
  bne updp1vtvd
  lda p1gy
  cmp maxp1gy
  bne updp1vtvd
  
  lda #maxvvu
  sta p1vvi
  lda #maxvvd
  sta p1vvt

  bne updp1vvd
updp1vvdown:
  lda #maxvvd
  sta p1vvt
updp1vtvd:
  lda p1vvi
  cmp p1vvt
  beq updp1vvd
  bcc updp1vaccel
  cmp #(vvzero+2)
  bcs updp1vdecel2
  dec p1vvi
  bne updp1vvd
updp1vdecel2:
  sec
  sbc #2
  sta p1vvi
  bne updp1vvd  
updp1vaccel:
  cmp #(vvzero-1)
  bcc updp1vaccel2
  inc p1vvi
  bne updp1vvd
updp1vaccel2:
  clc
  adc #2
  sta p1vvi
updp1vvd:
  lda p1vvi
  sec
  sbc #vvzero
  sta p1vva
  lda #0
  sbc #0
  sta p1vva+1
  rts



updp1p:
  // vertical position first
  lda p1gy
  clc
  adc p1vva
  sta p1gy
  sta p1ly

  lda p1gy+1
  adc p1vva+1
  sta p1gy+1
  sta p1ly+1

  bmi updp1vpneg
  
  cmp maxp1gy+1
  bcc updp1vpt
  lda p1ly
  cmp maxp1gy
  bcc updp1vpt
 
  // moved below the bottom of the screen
  lda #0
  sta p1vva
  lda #vvzero
  sta p1vvi

  lda maxp1gy
  sta p1gy
  lda maxp1gy+1
  sta p1gy+1
  lda #(200-p1height-16)
  //lda #214
  //lda #230
  sta p1ly
  bne updp1hp
updp1vpneg:
  // move would have moved char above level
  lda #0
  sta p1gy
  sta p1gy+1
  sta p1vva

  lda #vvzero
  sta p1vvi

  //lda #50
  lda #scrrow0
  sta p1ly
  bne updp1hp
updp1vpt:
  // valid move wrt level vertical bounds
  // drop fractional part of position
  clc
  ror p1ly+1
  ror p1ly
  ror p1ly+1
  ror p1ly
  ror p1ly+1
  ror p1ly
  lda p1ly+1
  and #%00011111
  sta p1ly+1

updp1hp:
  lda p1gx
  clc
  adc p1hva
  sta p1gx  
  sta p1lx

  lda p1gx+1
  adc p1hva+1
  sta p1gx+1
  sta p1lx+1

  bmi updp1hpneg

  cmp maxp1gx+1
  bcc updp1hpt
  lda p1lx
  cmp maxp1gx
  bcc updp1hpt
  // if here, moved past right of level

  lda #0
  sta p1hva
  lda #hvzero
  sta p1hvi

  lda maxp1gx
  sta p1gx
  sta p1lx
  lda maxp1gx+1
  sta p1gx+1
  sta p1lx+1
  jmp updp1hpt
  ////lda #71
  //lda #69
  // lda #31
  // sta p1lx
  // lda #1
  // sta p1lx+1
  //jmp collide
updp1hpneg:
  // move would have moved char to left of level
  lda #0
  sta p1gx
  sta p1gx+1
  sta p1hva

  lda #hvzero
  sta p1hvi

  //lda #31
  lda #0
  sta p1lx
  lda #0
  sta p1lx+1
  jmp collide
updp1hpt:
  // get rid of the fractional portion
  ror p1lx+1
  ror p1lx 
  ror p1lx+1
  ror p1lx 
  ror p1lx+1
  ror p1lx 
  ror p1lx+1
  ror p1lx 
  lda p1lx+1
  and #%00001111
  sta p1lx+1

  // now subtract the column offset
  // multiply by 8 (shift right 3 to get column in x coords)
  lda SCR_column_first_visible
  sta colshift
  lda SCR_column_first_visible+1
  sta colshift+1
  rol colshift
  rol colshift+1
  rol colshift
  rol colshift+1
  rol colshift
  rol colshift+1
  lda colshift
  and #%11111000
  sta colshift 

  lda p1lx
  sec
  sbc colshift
  sta p1lx
  lda p1lx+1
  sbc colshift+1
  sta p1lx+1

collide:
  // now we're in pixel coordinates, check for collisions with any tiles
  // first convert pixel coordinates to screen xy coordinates (x: 0..39, y: 0..24)
//  lda $d000
//  sec
//  sbc #31
//  sta p1sx
//  lda $d010
//  and #%00000001
//  sbc #0
//  sta p1sx+1
  lda p1lx
  sta p1sx
  lda p1lx+1
  sta p1sx+1

  ror p1sx+1
  ror p1sx
  ror p1sx+1
  ror p1sx
  ror p1sx+1
  ror p1sx
  //lda p1sx
  //and #%00111111
  //sta p1sx

//  lda $d001
//  sec
//  sbc #50
//  ror
//  ror
//  ror
//  and #%00011111
//  sta p1sy
  lda p1ly
  ror
  ror
  ror
  and #%00011111
  sta p1sy

  lda p1hva
  bmi collidel
  beq collidez
  // moving right
  lda p1vva
  bmi collideru
  beq colliderz
  // moving right and down
  lda #$ff
  sta tmp0
  jmp collided

collideru:
  // moving right and up
  lda #$fa
  sta tmp0
  jmp collided

colliderz:
  // moving right, vertical zero
  lda #$f0
  sta tmp0
  jmp collided
collidez:
  // not moving horiz
  lda p1vva
  bmi collidezu
  beq collidezz
  // not moving horiz, moving down
  lda #$0f
  sta tmp0
  jmp collided

collidezu:
  // not moving horiz, moving up
  lda #$0a
  sta tmp0
  jmp collided
collidel:
  // moving left
  lda p1vva
  bmi collidelu
  beq collidelz
  // moving left, moving down
  lda #$af
  sta tmp0
  jmp collided

collidelu:
  // moving left, moving up
  lda #$aa
  sta tmp0
  jmp collided
collidelz:
  // moving left, not moving vert
  lda #$a0
  sta tmp0
  lda #%11000000
  sta zpb7
  jmp collided

//collidell:
//collide
//  lda (mdptr),Y
//  and #%
//
//  // using the run itself as the collision rectangle.
//  // at this point, zpb7 contains the start of the run, mdbl is the width
//
//  inx
//  cpx #scrheight
//  bne collidel
//
collidezz:
  // not moving horiz, not moving vert
  lda #$00
  sta tmp0

collided:
  lda p1lx
  clc
  adc #31
  sta p1sx
  lda p1lx+1
  adc #0
  sta p1sx+1

  lda p1sx
  sec
  sbc SCR_scroll_offset
  sta p1sx
  lda p1sx+1
  sbc #0
  sta p1sx+1

  lda p1ly
  clc
  adc #50
  sta p1sy

  // sprite position is now calculated and stored in p1sx/p1sy, but we might
  // need to scroll which will impact the sprite position
  lda p1sx+1
  bne updp1psprite // no need to scroll if well past scroll point
  lda p1sx
  cmp #scrollmax
  bcs updp1hpsl
  cmp #scrollmin
  bcc updp1hpsr
  bcs updp1psprite
updp1hpsl:
  // greater than or equal to scrollmax, scroll left if moving right
  lda p1hva
  beq updp1psprite
  bmi updp1psprite
  // moving right, try to scroll
  lda p1sx
  sec
  sbc #scrollmax
  sta SCR_scroll_in
  jsr SCR_scroll_left
  // sprite position is new sprite position minus amount we scrolled
  lda p1sx
  sec
  sbc SCR_scroll_out
  sta p1sx
  // note: no need to update p1sx+1 because we scroll before sprite gets
  //   var enough along for msb to be set
  bne updp1psprite
updp1hpsr:
  // less than scrollmin, scroll right if moving left
  lda p1hva
  beq updp1psprite
  bpl updp1psprite
  // moving left, try to scroll
  lda #scrollmin
  sec
  sbc p1sx
  sta SCR_scroll_in
  jsr SCR_scroll_right
  // sprite position is new sprite position plus amount we scrolled
  lda p1sx
  clc
  adc SCR_scroll_out
  sta p1sx
updp1psprite:
  lda p1sy
  sta $d001
  lda p1sx
  sta $d000
  lda p1sx+1
  bne updp1pmsb
  lda $d010
  and #%11111110
  sta $d010
  jmp updp1pd
updp1pmsb:
  lda $d010
  ora #%00000001
  sta $d010
updp1pd:
  rts

// read a joystick
// inputs
//   A - joystick port value
injs:
  lsr
  rol ebu
  lsr
  rol ebd
  lsr
  rol ebl
  lsr
  rol ebr
  lsr
  rol ebp
  rts

gettime:
  jsr $ffde
  sty time+2
  stx time+1
  sta time
  rts

// data area
minx:        .byte 0,0
maxx:        .byte 0,0
miny:        .byte 0,0
maxy:        .byte 0,0
ptime:       .byte 0,0,0
etime:       .byte 0,0,0
time:        .byte 0,0,0

p1hvi:       .byte 0
p1hva:       .byte 0,0
p1gx:        .byte 0,0
p1lx:        .byte 0,0
p1sx:        .byte 0,0
p1vvi:       .byte 0
p1vva:       .byte 0,0
p1gy:        .byte 0,0
p1ly:        .byte 0,0 // 2 bytes due to a quirk in calculation
p1sy:        .byte 0
p1hvt:       .byte 0
p1vvt:       .byte 0

// event buffers for each joystick press
ebl:       .byte 0
ebr:       .byte 0
ebu:       .byte 0
ebd:       .byte 0
ebp:       .byte 0

tmp0:      .byte 0
tmp1:      .byte 0

maxp1gx:   .byte 0,0
maxp1gy:   .byte 0,0

colshift:  .byte 0,0

collisions: .byte 0
collrectx1: .fill 12,0
collrectx2: .fill 12,0
collrecty1: .fill 12,0
collrecty2: .fill 12,0

frame: .byte 0

