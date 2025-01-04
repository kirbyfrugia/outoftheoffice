  *=$8000 "Office"

//.var hvzero    = 127
//.var maxhvl    = 88
//.var maxhvr    = 166
//
//.var vvzero    = 127
//.var maxvvu    = 88
//.var maxvvd    = 166

.var hvzero    = 127
.var maxhvl    = 88
.var maxhvr    = 166

.var vvzero    = 127
.var maxvvu    = 93
.var maxvvd    = 161

  jmp init

#import "data.asm"
#import "const.asm"
#import "utils.asm"
#import "engine.asm"

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
 
  jsr initui
  jsr initsys
 jsr loadmap
  jsr redraw
  jsr initspr

  lda #0
  sta ENG_column0

  lda #38
  sec
  sbc #scrwidth
  sta ENG_max_column0
  lda #0
  sta ENG_max_column0+1

loop:
  lda $d012
  cmp #$f8
  bne loop 
  
  lda $dc00
  jsr injs
  jsr updp1hv
  jsr updp1vv
  jsr updp1p
  jsr log
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
  iny
  bne clsl
  rts

initsys:
  // turn on multiclr char mode
  lda $d016
  ora #%00010000
  sta $d016

  // // use our in-memory charset
  // lda $d018
  // and #%11110000
  // ora #%00001000
  // sta $d018

  lda #0
  sta ENG_scroll_offset
  lda #%00000111
  sta ENG_scroll_register

  lda $d016
  and #%11110000 // enable smooth scrolling
  ora ENG_scroll_register  // set initial scroll
  sta $d016

  rts

initspr:
  ldx #63
copyspr:
  lda p1spr,X
  sta $3000,X
  //sta $3040,X
  //sta $3080,X
  dex
  bpl copyspr

  // set sprite multi colors
  lda #sprmc0
  sta $d025
  lda #sprmc1
  sta $d026

  ldx #192
  stx $07f8 //spr ptr
  //inx
  //stx $07f8+1
  //inx
  //stx $07f8+2

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
//   ldx #9
//   stx fdev

//   ldy #0
// lml:
//   lda strlevel3,y
//   beq lmld
//   sta fname,y
//   iny
//   bne lml
// lmld:
//   sty fnamelen

//   // load main data
//   lda #<filedatas
//   sta zpb0
//   lda #>filedatas
//   sta zpb1 
//   jsr fload
//   lda fstatus
//   beq loadok
//   jmp loaderr
// loadok:

//   // load the char map
//   // set file name, append a "C" to the end of the name
//   ldx fnamelen
//   lda #67 // C
//   sta fname,x

//   lda #<chrtmdatas
//   sta zpb0
//   lda #>chrtmdatas
//   sta zpb1 
//   inc fnamelen
//   jsr fload
//   dec fnamelen
//   lda #0
//   ldx fnamelen
//   sta fname,x
//   lda fstatus
//   bne loaderr

//   // load the metadata map
//   // set file name, append a "M" to the end of the name
//   ldx fnamelen
//   lda #77 // M
//   sta fname,x

//   lda #<mdtmdatas
//   sta zpb0
//   lda #>mdtmdatas
//   sta zpb1 
//   inc fnamelen
//   jsr fload
//   dec fnamelen
//   lda #0
//   ldx fnamelen
//   sta fname,x
//   lda fstatus
//   bne loaderr

//   lda bgclr
//   sta $d021
//   lda bgclr1
//   sta $d022
//   lda bgclr2
//   sta $d023

//   lda #25
//   sta tmrowc
//   lda #scrrow0
//   sta tmrow0
//   lda #0
//   sta ENG_column0
//   sta ENG_column0+1

//   lda chrtmcolc
//   sta tmcolc
//   lda chrtmcolc+1
//   sta tmcolc+1
//   jmp loadd
// loaderr:
//   jsr emptyscrn
// loadd:
//   jsr updscrn
//   jsr drawscrn

  lda #36
  sta maxp1lx
  lda #0
  sta maxp1lx+1

  // multiply by 24 to go from column count to pixels
  // and then shift 3 more to the left to remove fractional portion
  lda maxp1lx
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  rol maxp1lx
  rol maxp1lx+1
  lda maxp1lx
  and #%10000000
  sta maxp1lx

  lda #(200-p1height-16)
//  lda #164
  sta maxp1ly
  lda #0
  sta maxp1ly+1

  rol maxp1ly
  rol maxp1ly+1
  rol maxp1ly
  rol maxp1ly+1
  rol maxp1ly
  rol maxp1ly+1
  lda maxp1ly
  and #%11111000
  sta maxp1ly


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

  // iny
  // iny
  // lda ENG_column0+1
  // jsr loghexit
  // iny
  // lda ENG_column0
  // jsr loghexit
  iny
  lda #43
  sta (zpb0),y
  iny
  lda ENG_scroll_offset
  jsr loghexit

  iny
  iny
  lda ENG_scroll_register
  jsr loghexit

  iny
  iny
  lda ENG_scrollx
  jsr loghexit

  iny
  iny
  lda $d010
  jsr loghexit
  iny
  lda $d000
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

  rts

// in its own subroutine just
// so we can time it
redraw:
  jsr gettime
  lda time
  sta ptime
  lda time+1
  sta ptime+1
  lda time+2
  sta ptime+2

  //jsr drawscrn
  jsr gettime

  lda time
  sec
  sbc ptime
  sta etime
  lda time+1
  sbc ptime+1
  sta etime+1
  lda time+2
  sbc ptime+2
  sta etime+2
  rts


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
// The 3 least significant bits of the actual velocity and position are fractional
//   and are truncated when updating the sprite's actual position on the screen.
//   This allows smoother and smaller movement, acceleration, etc.
// Key variables:
//   p1hvi - horiz vel,indexed
//   p1hva - horiz vel,actual
//   p1gx  - global xpos
//   p1lx  - local xpos (relative to column at far left of screen), minus fractional portion
//   p1sx  - screen xpos (screen tile coords)
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
  cmp maxp1ly+1
  bne updp1vtvd
  lda p1gy
  cmp maxp1ly
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
  lda p1vvi
  sec
  sbc #1
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
  
  cmp maxp1ly+1
  bcc updp1vpt
  lda p1ly
  cmp maxp1ly
  bcc updp1vpt
 
  // moved below the bottom of the screen
  lda #0
  sta p1vva
  lda #vvzero
  sta p1vvi

  lda maxp1ly
  sta p1gy
  lda maxp1ly+1
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

  cmp maxp1lx+1
  bcc updp1hpt
  lda p1lx
  cmp maxp1lx
  bcc updp1hpt
  // if here, moved past right of level

  lda #0
  sta p1hva
  lda #hvzero
  sta p1hvi

  lda maxp1lx
  sta p1gx
  lda maxp1lx+1
  sta p1gx+1
  ////lda #71
  //lda #69
  lda #31
  sta p1lx
  lda #1
  sta p1lx+1
  jmp collide
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
  and #%00011111
  sta p1lx+1

  // now subtract the column offset
  // multiply by 8 (shift right 3 to get column in x coords)
  lda ENG_column0
  sta colshift
  lda ENG_column0+1
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
  sbc ENG_scroll_offset
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
  bne updp1psprite
  lda p1sx
  cmp #scrollmax
  bcs updp1hpsl
  cmp #scrollmin
  bcc updp1hpsr
  bcs updp1psprite
updp1hpsl:
  // greater than scrollmax, scroll left if moving right
  lda p1hva
  beq updp1psprite
  bmi updp1psprite
  // moving right, try to scroll
  lda p1sx
  sec
  sbc #scrollmax
  sta ENG_scrollx
  jsr scrolll
  // sprite position is new sprite position minus amount we scrolled
  lda p1sx
  sec
  sbc ENG_scrollx
  sta p1sx
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
  sta ENG_scrollx
  jsr scrollr
  // sprite position is new sprite position plus amount we scrolled
  lda p1sx
  clc
  adc ENG_scrollx
  sta p1sx
  lda #0
  sta p1sx+1
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

maxp1lx:   .byte 0,0
maxp1ly:   .byte 0,0

colshift:  .byte 0,0

collisions: .byte 0
collrectx1: .fill 12,0
collrectx2: .fill 12,0
collrecty1: .fill 12,0
collrecty2: .fill 12,0
