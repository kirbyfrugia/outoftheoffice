#import "data/level1.asm"
#import "data/sprites.asm"

.disk [filename="office.d64", name="OFFICE", id="O1" ] {
  [name="OFFICE", type="prg", segments="Office"],
  [name="SPRITES", type="prg", segments="sprites"],
  [name="LEVEL1", type="prg", segments="level1"]
}

// .segment Office [outPrg="office.prg", start=$8000]
.segment Office [outPrg="office.prg", start=$6000]
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
#import "data/song-kirby.asm"
// #import "data/song-devils-dream.asm"
#import "screen.asm"

// Modifies X and A
.macro copy_sprite(src, dest) {
  ldx #63
copy_sprite_data:
  lda src, x
  sta dest, x
  dex
  bpl copy_sprite_data
}

.macro voice_handler(voice_control, voice_hf, voice_lf, melody_voice_control, melody_dur_left, melody_index, melody, melody_end, next_jump_point) {
  dec melody_dur_left
  bne next_jump_point // continue playing current note, still playing note
melody_next_note:
  ldx melody_index
  cpx #(melody_end - melody)
  bne melody_play_note
  // looped to end of song
  // release note
  lda voice_control
  and #%11111110
  sta voice_control
  ldx #0
  stx melody_index
melody_play_note:
  lda melody, x // hf
  beq melody_play_note_rest
  sta voice_hf
  inx
  lda melody, x  // lf
  sta voice_lf
  inx
  lda melody, x // duration of note
  sta melody_dur_left
  lda #melody_voice_control
  sta voice_control
  jmp melody_play_note_played
melody_play_note_rest:
  lda voice_control
  and #%11111110
  sta voice_control
  ldx #2
  lda melody, x
  sta melody_dur_left
melody_play_note_played:
  lda melody_index
  clc
  adc #3
  sta melody_index
}

.macro play_sound_effect(pulse_lo, pulse_hi, attack_decay, sustain_release, freq_lo, freq_hi, waveform, num_ticks) {
  lda #pulse_lo
  sta VOICE3_PULSE_LO
  lda #pulse_hi
  sta VOICE3_PULSE_HI

  lda #attack_decay
  sta VOICE3_ENV_AD
  lda #sustain_release
  sta VOICE3_ENV_SR

  lda #freq_lo
  sta VOICE3_LF
  lda #freq_hi
  sta VOICE3_HF

  lda #waveform
  sta VOICE3_CONTROL

  lda #num_ticks
  sta sound_effect_ticks_left
}

irq:
  pha
  txa
  pha
  tya
  pha

  lda sound_started
  bne sound_is_started
  jmp sound_done
sound_is_started:
  lda sound_effect_new_irq
  beq sound_effect_process

  // if here, we're loading a new sound from the ggame loop
  ldx sound_effect_index_irq

  lda sound_effects_pulse_lo, x
  sta VOICE3_PULSE_LO
  lda sound_effects_pulse_hi, x
  sta VOICE3_PULSE_HI

  lda sound_effects_attack_decay, x
  sta VOICE3_ENV_AD
  lda sound_effects_sustain_release, x
  sta VOICE3_ENV_SR

  lda sound_effects_freq_lo, x
  sta VOICE3_LF
  lda sound_effects_freq_hi, x
  sta VOICE3_HF

  lda sound_effects_waveform, x
  sta VOICE3_CONTROL

  lda sound_effects_num_ticks, x
  sta sound_effect_ticks_left

  lda sound_effects_sweep_freq_lo, x
  sta sound_effect_sweep_freq_lo

  lda sound_effects_sweep_freq_hi, x
  sta sound_effect_sweep_freq_hi

  lda sound_effects_sweep_num_ticks, x
  sta sound_effect_sweep_ticks_left

  lda #0
  sta sound_effect_new_irq

sound_effect_process:
  // let's deal with sound effects
  dec sound_effect_ticks_left
  bne sound_effect_sweep
  // done playing this sound effect
  lda VOICE3_CONTROL
  and #%11111110 // gate off
  sta VOICE3_CONTROL

  // set duration to 1 intentionally, gets decremented even if no sound is playing
  lda #1
  sta sound_effect_ticks_left
  sta sound_effect_sweep_ticks_left
  bne music
sound_effect_sweep:
  dec sound_effect_sweep_ticks_left
  beq sound_effect_sweep_done
  // still sweeping
  lda VOICE3_LF
  clc
  adc sound_effect_sweep_freq_lo
  sta VOICE3_LF
  lda VOICE3_HF
  adc sound_effect_sweep_freq_hi
  sta VOICE3_HF
  jmp music
sound_effect_sweep_done:
  lda #1
  sta sound_effect_sweep_done
music:
  // now let's deal with the music
  dec melody_frames_until_16th
  beq on_16th
  jmp sound_done
on_16th:
  lda #melody_tempo
  sta melody_frames_until_16th

  voice_handler(VOICE1_CONTROL, VOICE1_HF, VOICE1_LF, melody_v1_control, melody_v1_dur_left, melody_v1_index, melody_v1, melody_v1_end, melody_v1_done)
melody_v1_done:
  voice_handler(VOICE2_CONTROL, VOICE2_HF, VOICE2_LF, melody_v2_control, melody_v2_dur_left, melody_v2_index, melody_v2, melody_v2_end, melody_v2_done)
melody_v2_done:

sound_done:
  lda SCR_buffer_ready
  beq irqd
  jsr swap_buffers

irqd:
  SCR_update_scroll_register()
  lda #1
  sta frame_tick

  // ack raster irq
  asl $d019

  pla
  tay
  pla
  tax
  pla

  jmp $ea81 // let the kernal do its thing 

init:
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

  set_on_ground()

  lda #0
  sta p1gx+1
  sta p1lx_prev+1

  lda #8
  sta p1gx
  sta p1lx_prev
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
  sta frame_phase
  sta current_buffer

  lda #30
  sta animation_frame

  jsr initui
  jsr initsys
  jsr initirq
  jsr initsound

  jsr SCR_load_sprite_sheet

  lda #level1_MAP_WID
  sta SCR_tile_level_width
  jsr SCR_loadmap
  lda #0
  sta SCR_first_visible_column
  sta SCR_first_visible_column+1

  lda #level1_MAP_WID
  clc
  rol
  sta SCR_first_visible_column_max
  rol SCR_first_visible_column_max+1

  lda SCR_first_visible_column_max
  sec
  sbc #scrwidth
  sta SCR_first_visible_column_max
  lda SCR_first_visible_column_max+1
  sbc #0
  sta SCR_first_visible_column_max+1
  jsr loadmap

  jsr initspr

  
  jsr SCR_init_screen
  jsr SCR_draw_screen
  jsr startsound

game_loop:
  lda frame_tick
  beq game_loop

  // disable interrupts and set variables used
  // by the irq handler
  sei
  lda #0
  sta frame_tick
  lda sound_effect_new_game_loop
  beq no_new_sound
  // if here, a new sound was triggered in the game loop last loop
  lda sound_effect_index_game_loop
  sta sound_effect_index_irq       // index of new sound to play, to be read by irq
  lda #1
  sta sound_effect_new_irq         // flag indicating we have a new sound to load for the irq handler
no_new_sound:
  cli
  // end of section with disabled interrupts
  lda #0
  sta sound_effect_new_game_loop   // clear game loop flag

  jsr updanim
  // jsr log

  // get input, do game logic, possibly move screen mem
  lda $dc00
  jsr injs
  jsr updp1hv
  jsr updp1vv
  jsr updp1p

game_loop_swap:
  // wait for buffer to swap
  lda SCR_buffer_ready
  bne game_loop_swap

  jsr shift_color_mem
  jmp game_loop

swap_buffers:
  lda SCR_buffer_ready
  beq swap_buffersd // no need to swap
  lda SCR_buffer_flag
  beq sb_screen0800

  lda $d018
  and #%00001111
  ora #%00010000 // screen location 1024, $0400
  sta $d018
  lda #0
  sta SCR_buffer_flag
  beq swap_buffers_swapped
sb_screen0800:
  lda $d018
  and #%00001111
  ora #%00100000 // screen location 2048, $0800
  sta $d018
  lda #1
  sta SCR_buffer_flag
swap_buffers_swapped:
  lda #0
  sta SCR_buffer_ready
  // SCR_update_scroll_register()
swap_buffersd:
  rts

shift_color_mem:
  lda SCR_color_flag
  beq shift_color_memd // no need to shift color memory
  cmp #%00000001
  beq shift_color_mem_left
  jsr SCR_move_color_right
  jmp shift_color_memd
shift_color_mem_left:
  jsr SCR_move_color_left
shift_color_memd:
  lda #0
  sta SCR_color_flag
  rts

cls:
  ldy #0
clsl:
  lda #1
  sta $d800,y
  sta $d800+$0100,y
  sta $d800+$0200,y
  sta $d800+$0300,y
//  lda #252
  lda #0
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

initirq:
  // disable interrupts
  sei

  // // switch out basic and kernal
  // lda $01
  // and #%11111000
  // ora #%00000100
  // sta $01

  // lda #%11000100
  // // and #%11111110
  // sta $0001

  // switch off cia interrupts
  lda #$7f
  sta $dc0d
  sta $dd0d

  // clear any pending interrupts from CIA-1/2
  lda $dc0d
  lda $dd0d

  // clear high raster bit
  lda $d011
  and #%01111111
  sta $d011

  // clear any pending raster interrupts
  lda #$0f
  sta $d019

  // raster line where interrupt will occur
  lda #$fa
  sta $d012

  // lda $0314
  // sta old_irq
  // lda $0315
  // sta old_irq+1

  // set interrupt handling routine
  lda #<irq
  sta $0314
  lda #>irq
  sta $0315

  // // set interrupt handling routine if unload kernal
  // lda #<irq
  // sta $fffe
  // lda #>irq
  // sta $ffff

  // enable raster interrupt source
  lda #%00000001
  sta $d01a

  cli // re-enable interrupts
  rts

initsound:
  // clear the sid chip
  ldx #24
  lda #0
initsound_clearsid:
  sta SID_BASE, x
  dex
  bpl initsound_clearsid

  lda #melody_cutoff_filter_lo
  sta SID_FILT_CUTOFF_LB

  lda #melody_cutoff_filter_hi
  sta SID_FILT_CUTOFF_HB

  lda #melody_filter_resonance
  sta SID_FILT_RESONANCE

  lda #melody_filter_volume
  sta SID_FILT_VOL

  lda #melody_v1_attack_decay
  sta VOICE1_ENV_AD
  lda #melody_v1_sustain_release
  sta VOICE1_ENV_SR
  lda #melody_v2_attack_decay
  sta VOICE2_ENV_AD
  lda #melody_v2_sustain_release
  sta VOICE2_ENV_SR
  // lda #melody_v3_attack_decay
  // sta VOICE3_ENV_AD
  // lda #melody_v3_sustain_release
  // sta VOICE3_ENV_SR

  lda #0
  sta sound_effect_index_irq
  sta sound_effect_index_game_loop
  sta sound_effect_new_irq
  sta sound_effect_new_game_loop
  sta melody_v1_index
  sta melody_v1_dur_left
  sta melody_v2_index
  sta melody_v2_dur_left
  sta melody_v3_index
  sta melody_v3_dur_left
  sta sound_effect_sweep_freq_lo
  sta sound_effect_sweep_freq_hi
  sta sound_started
  lda #melody_tempo
  sta melody_frames_until_16th
  rts

startsound:
  // on init, move to end of song with 1 16th notes remaining
  // so that we loop back to start in the irq

  lda #(melody_v1_end - melody_v1)
  sta melody_v1_index
  lda #(melody_v2_end - melody_v2)
  sta melody_v2_index
  // lda #(melody_v3_end - melody_v3)
  // sta melody_v3_index

  lda #1
  sta sound_effect_ticks_left
  sta sound_effect_sweep_ticks_left
  sta melody_v1_dur_left
  sta melody_v2_dur_left
  sta melody_v3_dur_left
  sta sound_started
  rts

initspr:
  copy_sprite(sprite_image_0, SCR_sprite_data)

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

  lda #194
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

  lda SCR_first_visible_column_max
  clc
  adc #scrwidth
  sta maxp1gx
  lda SCR_first_visible_column_max+1
  adc #0
  sta maxp1gx+1

  lda maxp1gx
  sec
  sbc #2 // player width
  sta maxp1gx
  lda maxp1gx+1
  sbc #0
  sta maxp1gx+1

  // lda #58
  // sta maxp1gx
  // lda #$00
  // sta maxp1gx+1

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

  lda #(200-p1height-40)
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
  lda SCR_buffer_flag
  bne log_back_line1
  lda #$70
  sta zpb0
  lda #$07
  sta zpb1
  bne log_line1
log_back_line1:
  lda #$70
  sta zpb0
  lda #$0b
  sta zpb1
log_line1:
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
  lda p1sx+1
  jsr loghexit
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
  lda SCR_first_visible_column+1
  jsr loghexit
  iny
  lda SCR_first_visible_column
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
  lda SCR_buffer_flag
  bne log_back_line2
  lda #$98
  sta zpb0
  lda #$07
  sta zpb1
  bne log_line2
log_back_line2:
  lda #$98
  sta zpb0
  lda #$0b
  sta zpb1
log_line2:

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
  lda collide_pixels_x
  jsr loghexit
  iny
  lda collide_pixels_y
  jsr loghexit

  iny
  iny
  lda p1cx2
  jsr loghexit
  iny
  lda p1cy2
  jsr loghexit

  iny
  iny
  lda on_ground
  jsr loghexit

  // next row
  lda SCR_buffer_flag
  bne log_back_line3
  lda #$c0
  sta zpb0
  lda #$07
  sta zpb1
  bne log_line3
log_back_line3:
  lda #$c0
  sta zpb0
  lda #$0b
  sta zpb1
log_line3:

  ldy #1
  lda melody_frames_until_16th
  jsr loghexit
  iny
  iny
  lda melody_v1_index
  jsr loghexit
  iny
  iny
  lda melody_v1_dur_left
  jsr loghexit
  iny
  iny
  lda melody_v2_index
  jsr loghexit
  iny
  iny
  lda melody_v2_dur_left
  jsr loghexit
  iny
  iny
  lda melody_v3_index
  jsr loghexit
  iny
  iny
  lda melody_v3_dur_left
  jsr loghexit
  iny
  iny
  lda sound_effect_ticks_left
  jsr loghexit
  iny
  iny
  lda sound_effect_sweep_ticks_left
  jsr loghexit
  iny
  iny
  lda VOICE3_LF
  jsr loghexit
  iny
  iny
  lda VOICE3_HF
  jsr loghexit

  

  

//   ldy #1
//   lda collision_row_even
//   jsr loghexit
//   iny
//   lda collision_column_even
//   jsr loghexit

//   ldy #10
//   ldx #0
// log_line_3_loop:
//   lda collision_metadata_row0, x
//   jsr loghexit
//   iny
//   lda collision_metadata_row1, x
//   jsr loghexit
//   iny
//   lda collision_metadata_row2, x
//   jsr loghexit
//   iny
//   lda collision_metadata_row3, x
//   jsr loghexit
//   iny
//   iny
//   inx
//   cpx #3
//   bne log_line_3_loop

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
// The 4 least significant bits of the actual velocity and position are fractional
//   and are truncated when updating the sprite's actual position on the screen.
//   This allows smoother and smaller movement, acceleration, etc.
// Key variables:
//   p1hvi - horiz vel,indexed
//   p1hva - horiz vel,actual
//   p1gx  - global xpos, including fractional portion
//   p1lx  - local xpos (relative to column at far left of screen), minus fractional portion, pixel coordinates
//   p1sx  - sprite xpos, pixel coordinates
//   p1vvi - vert vel,indexed
//   p1vva - vert vel,actual
//   p1gy  - global ypos
//   p1ly  - local ypos
//   p1hvt - horiz target vel
//   p1vvt - vert target vel
//   maxhvl - max velocity when moving left
//   maxhvr - max velocity when moving right

.macro set_on_ground() {
  lda #0
  sta on_ground
  sta p1vva
  lda #vvzero
  sta p1vvi
}

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
  lda on_ground
  bne updp1vv_not_on_ground

  // only jump on new button presses and on ground
  lda ebp
  and #%00000011
  cmp #%00000010
  bne updp1vv_on_ground
  // if here, jumping
  // Play jump sound effect
  lda #0 // jump index
  sta sound_effect_index_game_loop
  lda #1
  sta sound_effect_new_game_loop

  lda #maxvvu
  sta p1vvi
  lda #maxvvd
  sta p1vvt

  jmp updp1vvd
updp1vv_not_on_ground:
  // if not on the ground, target velocity is always
  // max falling speed
  lda #maxvvd
  sta p1vvt
  jmp updp1vtvd
updp1vv_on_ground:
  lda #vvzero
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

// loads the tile at the given row and column
// and stores the tile id to X
.macro get_collision_tile(tile_row, tile_column) {
  tya
  pha
  ldy tile_row
  cpy #10
  bcs get_collision_tile_empty // past bottom of screen
  lda SCR_rowptrs_lo, y
  sta SCR_TILE_ROW_CURR
  lda SCR_rowptrs_hi, y
  sta SCR_TILE_ROW_CURR+1

  ldy tile_column
  lda (SCR_TILE_ROW_CURR), y
  tax
  lda SCR_char_tileset_tag, x
  beq get_collision_tile_empty // filter out tiles that aren't collidable
  bne get_collision_tile_done
get_collision_tile_empty:
  ldx #0
get_collision_tile_done:
  pla
  tay
}

// assuming the tile id is in X, get the character material
// at tile_char within the tile, store the result in
// collision_metadata_row indexed by Y.
.macro set_material(tile_char, collision_metadata_row) {
  txa
  pha
  lda SCR_char_tileset_tag, x    // get tile collision info
  sta collision_metadata_row, y
  lda tile_char, x               // get the character
  tax
  lda SCR_char_attribs, x        // get the char collision info (material)
  and collision_metadata_row, y
  sta collision_metadata_row, y
  pla
  tax
}

collide_prep:
  // now we're in global, pixel coordinates, get information needed
  // for collision detection
  lda p1ly
  and #%11111000
  sta p1cy
  lda p1ly
  sec
  sbc p1cy
  sta p1cy
  clc
  adc #p1height
  sta p1cy2

  lda p1ly
  // rotate right 3 to go from pixels to screen chars 
  ror
  ror
  ror
  sta collision_row_even
  // divide by 2 to get tile
  ror
  and #%00001111
  sta SCR_TILE_ROW

  lda collision_row_even
  and #%00000001
  sta collision_row_even

  // now we're in global, pixel coordinates, get information needed
  // for collision detection
  

  // set the far right location of the character
  lda p1lx
  clc
  adc #p1width
  sta p1lx2
  lda p1lx+1
  adc #0
  sta p1lx2+1

  lda p1lx
  and #%11111000 // truncate to nearest screen char to the left
  sta p1cx
  lda p1lx
  sec
  sbc p1cx
  sta p1cx // now contains distance in pixels from p1lx to the left of player
  clc
  adc #p1width
  sta p1cx2

  lda p1lx
  sta SCR_TILE_COL
  lda p1lx+1
  // rotate right 3 to go from pixels to screen chars 
  ror
  ror SCR_TILE_COL
  ror
  ror SCR_TILE_COL
  ror
  ror SCR_TILE_COL
  ldx SCR_TILE_COL
  stx collision_column_even
  // divide by 2 to get tile
  ror
  ror SCR_TILE_COL

  lda collision_column_even
  and #%00000001
  sta collision_column_even

  // TODO:
  //   let's have the char contain the collision information in the material
  //   let's have the tile allow us to override it. So if the tile has a tag of #0, then
  //   ignore the collision infoormation
  // TODO:
  //   store the char material data the same way we store the tile data (charset_attrib_L1_data)

  // now SCR_TILE_COL contains the first x tile
  lda collision_column_even
  beq column_even
  jmp column_odd
column_even:
  // if here, we have an even column
  lda collision_row_even
  beq column_even_row_even
  jmp column_even_row_odd
column_even_row_even:
  // if here, even column, even row
  // upper left collision char is in upper left of tile
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  ldy #0
  set_material(SCR_tiles_ul, collision_metadata_row0)
  set_material(SCR_tiles_ll, collision_metadata_row1)
  iny
  set_material(SCR_tiles_ur, collision_metadata_row0)
  set_material(SCR_tiles_lr, collision_metadata_row1)
  
  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ul, collision_metadata_row0)
  set_material(SCR_tiles_ll, collision_metadata_row1)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ul, collision_metadata_row2)
  set_material(SCR_tiles_ll, collision_metadata_row3)

  dec SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  ldy #0
  set_material(SCR_tiles_ul, collision_metadata_row2)
  set_material(SCR_tiles_ll, collision_metadata_row3)
  iny
  set_material(SCR_tiles_ur, collision_metadata_row2)
  set_material(SCR_tiles_lr, collision_metadata_row3)

  jmp collision_prep_done
column_odd:
  lda collision_row_even
  beq column_odd_row_even
  jmp column_odd_row_odd
column_odd_row_even:
  // if here, odd column, even row
  // upper left collision char is in upper right of tile
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  ldy #0
  set_material(SCR_tiles_ur, collision_metadata_row0)
  set_material(SCR_tiles_lr, collision_metadata_row1)

  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ul, collision_metadata_row0)
  set_material(SCR_tiles_ll, collision_metadata_row1)
  iny
  set_material(SCR_tiles_ur, collision_metadata_row0)
  set_material(SCR_tiles_lr, collision_metadata_row1)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ur, collision_metadata_row2)
  set_material(SCR_tiles_lr, collision_metadata_row3)
  dey
  set_material(SCR_tiles_ul, collision_metadata_row2)
  set_material(SCR_tiles_ll, collision_metadata_row3)

  dec SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  dey
  set_material(SCR_tiles_ur, collision_metadata_row2)
  set_material(SCR_tiles_lr, collision_metadata_row3)

  jmp collision_prep_done
column_odd_row_odd:
  // if here, odd column, odd row
  // upper left collision char is in lower right of tile
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  ldy #0
  set_material(SCR_tiles_lr, collision_metadata_row0)

  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ll, collision_metadata_row0)
  iny
  set_material(SCR_tiles_lr, collision_metadata_row0)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ur, collision_metadata_row1)
  set_material(SCR_tiles_lr, collision_metadata_row2)
  dey
  set_material(SCR_tiles_ul, collision_metadata_row1)
  set_material(SCR_tiles_ll, collision_metadata_row2)

  dec SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  dey
  set_material(SCR_tiles_ur, collision_metadata_row1)
  set_material(SCR_tiles_lr, collision_metadata_row2)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ur, collision_metadata_row3)

  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ul, collision_metadata_row3)
  iny
  set_material(SCR_tiles_ur, collision_metadata_row3)

  jmp collision_prep_done
column_even_row_odd:
  // if here, even column, odd row
  // upper left collision char is in lower left of tile
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  ldy #0
  set_material(SCR_tiles_ll, collision_metadata_row0)
  iny
  set_material(SCR_tiles_lr, collision_metadata_row0)

  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ll, collision_metadata_row0)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ul, collision_metadata_row1)
  set_material(SCR_tiles_ll, collision_metadata_row2)

  dec SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  dey
  set_material(SCR_tiles_ur, collision_metadata_row1)
  set_material(SCR_tiles_lr, collision_metadata_row2)
  dey
  set_material(SCR_tiles_ul, collision_metadata_row1)
  set_material(SCR_tiles_ll, collision_metadata_row2)

  inc SCR_TILE_ROW
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  set_material(SCR_tiles_ul, collision_metadata_row3)
  iny
  set_material(SCR_tiles_ur, collision_metadata_row3)

  inc SCR_TILE_COL
  get_collision_tile(SCR_TILE_ROW, SCR_TILE_COL)
  iny
  set_material(SCR_tiles_ul, collision_metadata_row3)
collision_prep_done:
  rts


collision_move_out_to_left:
  // stop character horizontal movement
  lda #0
  sta p1hva+1
  lda #$f8
  sta p1hva
  lda #(hvzero-8)
  sta p1hvi

  lda p1cx
  sec
  sbc collide_pixels_x
  sta p1cx
  
  lda p1cx2
  sec
  sbc collide_pixels_x
  sta p1cx2

  lda p1lx
  sec
  sbc collide_pixels_x
  sta p1lx
  sta p1gx
  lda p1lx+1
  sbc #0
  sta p1lx+1
  sta p1gx+1

  // move to global coordinates with fractional
  lda p1gx
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  ora #%00001111
  sta p1gx
  rts

collision_move_out_to_right:
  // stop character horizontal movement
  lda #0
  sta p1hva+1
  lda #8
  sta p1hva
  lda #(hvzero+8)
  sta p1hvi

  lda p1cx
  clc
  adc collide_pixels_x
  sta p1cx

  lda p1cx2
  clc
  adc collide_pixels_x
  sta p1cx2

  lda p1lx
  clc
  adc collide_pixels_x
  sta p1lx
  sta p1gx
  lda p1lx+1
  adc #0
  sta p1lx+1
  sta p1gx+1

  // move to global coordinates with fractional
  lda p1gx
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  and #%11110000
  //ora #%00000011 // add some subpixels so we're no longer colliding
  sta p1gx
  rts

collision_move_out_to_top:
  // stop character vertical movement
  // lda #0
  // sta p1vva
  // sta p1vva+1
  // lda #vvzero
  // sta p1vvi

  lda p1cy
  sec
  sbc collide_pixels_y
  sta p1cy

  lda p1cy2
  sec
  sbc collide_pixels_y
  sta p1cy2

  lda p1ly
  sec
  sbc collide_pixels_y
  sta p1ly
  sta p1gy
  lda p1ly+1
  sbc #0
  sta p1ly+1
  sta p1gy+1

  // move to global coordinates with fractional
  lda p1gy
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  // rol
  and #%11111000
  sta p1gy
  rts

collision_move_out_to_bottom:
  // stop character vertical movement
  lda #0
  sta p1vva
  sta p1vva+1
  lda #vvzero
  sta p1vvi

  lda p1cy
  clc
  adc collide_pixels_y
  sta p1cy

  lda p1cy2
  clc
  adc collide_pixels_y
  sta p1cy2

  lda p1ly
  clc
  adc collide_pixels_y
  sta p1ly
  sta p1gy
  lda p1ly+1
  adc #0
  sta p1ly+1
  sta p1gy+1

  // move to global coordinates with fractional
  lda p1gy
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  // rol
  and #%11111000
  sta p1gy

  rts

// Should only be called after collision detection
update_ground_status:
  // first check if character is at bottom of screen
  lda p1ly+1
  cmp maxp1gy+1
  bcc ugs_collisions
  lda p1ly
  cmp maxp1gy
  bcs ugs_on_ground
ugs_collisions:
  // TODO: do we really need to do this so many times?
  jsr collide_prep

  lda p1cy2
  // player isn't on the ground if their feet aren't about
  // to enter the next screen char down
  cmp #24
  bne ugs_not_on_ground
  ldx #0
  lda collision_metadata_row3, x
  and #%00100000
  bne ugs_on_ground
  inx
  lda collision_metadata_row3, x
  and #%00100000
  bne ugs_on_ground
  lda p1cx2
  cmp #17
  bcc ugs_not_on_ground
  inx
  lda collision_metadata_row3, x
  and #%00100000
  bne ugs_on_ground
ugs_not_on_ground:
  lda #1
  sta on_ground
  bne ugs_done
ugs_on_ground:
  set_on_ground()
ugs_done:
  rts

// TODO:
//   - Separate head collision from body to maybe help?
//   - Only do upper collision on specific "ceiling" type tiles. Then default
//     to colliding upwards first so we can glide along ceilings. None of the
//     other tiles have the upwards collision field set.
//   - Implement checking the right bits for collision
//see this todo^

// collision bits
// LRTBxxxx
collide_left_side:
  lda p1cx2
  cmp #17
  bcc cls_no_collision
  ldx #2
  lda collision_metadata_row0,x
  and #%10000000
  bne cls_collision
  lda collision_metadata_row1,x
  and #%10000000
  bne cls_collision
  lda collision_metadata_row2,x
  and #%10000000
  bne cls_collision
  lda p1cy2
  cmp #25
  bcc cls_no_collision
  lda collision_metadata_row3, x
  and #%10000000
  bne cls_collision
cls_no_collision:
  lda #0
  sta collide_pixels_x
  beq cls_done
cls_collision:
  lda p1cx2
  sec
  sbc #16
  sta collide_pixels_x
cls_done:
  rts

collide_right_side:
  ldx #0
  lda collision_metadata_row0, x
  and #%01000000
  bne crs_collision
  lda collision_metadata_row1, x
  and #%01000000
  bne crs_collision
  lda collision_metadata_row2, x
  and #%01000000
  bne crs_collision
  lda p1cy2
  cmp #25
  bcc crs_no_collision
  lda collision_metadata_row3, x
  and #%01000000
  bne crs_collision
crs_no_collision:
  lda #0
  sta collide_pixels_x
  beq crs_done
crs_collision:
  lda #8
  sec
  sbc p1cx
  sta collide_pixels_x
crs_done:
  rts

collide_top_side:
  lda p1cy2
  cmp #25
  bcc cts_no_collision
  ldx #0
  lda collision_metadata_row3, x
  and #%00100000
  bne cts_collision
  inx
  lda collision_metadata_row3, x
  and #%00100000
  bne cts_collision
  lda p1cx2
  cmp #17
  bcc cts_no_collision
  inx
  lda collision_metadata_row3, x
  and #%00100000
  bne cts_collision
cts_no_collision:
  lda #0
  sta collide_pixels_y
  beq cts_done
cts_collision:
  lda p1cy2
  sec
  sbc #24
  sta collide_pixels_y
cts_done:
  rts

collide_bottom_side:
  ldx #0
  lda collision_metadata_row0, x
  and #%00010000
  bne cbs_collision
  inx
  lda collision_metadata_row0, x
  and #%00010000
  bne cbs_collision
  lda p1cx2
  cmp #17
  bcc cbs_no_collision
  inx
  lda collision_metadata_row0, x
  and #%00010000
  bne cbs_collision
cbs_no_collision:
  lda #0
  sta collide_pixels_y
  beq cbs_done
cbs_collision:
  lda #8
  sec
  sbc p1cy
  sta collide_pixels_y
cbs_done:
  rts

collision_moving_up:
  jsr collide_prep
  jsr collide_bottom_side
  lda collide_pixels_y
  beq cmd_done
cmu_collision:
  jsr collision_move_out_to_bottom
cmu_done:
  rts

collision_moving_down:
  jsr collide_prep
  jsr collide_top_side
  lda collide_pixels_y
  bne cmd_collision
  beq cmd_done
cmd_collision:
  jsr collision_move_out_to_top
cmd_done:
  rts

collision_moving_left:
  jsr collide_prep
  jsr collide_right_side
  lda collide_pixels_x
  beq cml_done
  jsr collision_move_out_to_right
cml_done:
  rts


collision_moving_left_down:
  jsr collide_prep
  jsr collide_top_side
  lda collide_pixels_y
  beq cmld_right_side
  jsr collision_move_out_to_top
cmld_right_side:
  jsr collide_prep
  jsr collide_right_side
  lda collide_pixels_x
  beq cmld_done
  jsr collision_move_out_to_right
cmld_done:
  rts

collision_moving_left_up:
//   jsr collide_prep
//   jsr collide_right_side
//   lda collide_pixels_x
//   beq cmlu_bottom_side
//   jsr collision_move_out_to_right
// cmlu_bottom_side:
//   jsr collide_prep
//   jsr collide_bottom_side
//   lda collide_pixels_y
//   beq cmlu_done
//   jsr collision_move_out_to_bottom
// cmlu_done:
  jsr collide_prep
  jsr collide_bottom_side
  lda collide_pixels_y
  beq cmlu_right_side
  jsr collision_move_out_to_bottom
cmlu_right_side:
  jsr collide_prep
  jsr collide_right_side
  lda collide_pixels_x
  beq cmlu_done
  jsr collision_move_out_to_right
cmlu_done:
  rts

collision_moving_right:
  jsr collide_prep
  jsr collide_left_side
  lda collide_pixels_x
  bne cmr_collision
  beq cmr_done
cmr_collision:
  jsr collision_move_out_to_left
cmr_done:
  rts

collision_moving_right_down:
  jsr collide_prep
  jsr collide_top_side
  lda collide_pixels_y
  beq cmrd_left
  jsr collision_move_out_to_top
cmrd_left:
  jsr collide_prep
  jsr collide_left_side
  lda collide_pixels_x
  beq cmrd_done
  jsr collision_move_out_to_left
cmrd_done:
  rts

collision_moving_right_up:
//   jsr collide_prep
//   jsr collide_left_side
//   lda collide_pixels_x
//   beq cmru_bottom
//   jsr collision_move_out_to_left
// cmru_bottom:
//   jsr collide_prep
//   jsr collide_bottom_side
//   lda collide_pixels_y
//   beq cmru_done
//   jsr collision_move_out_to_bottom
// cmru_done:
  jsr collide_prep
  jsr collide_bottom_side
  lda collide_pixels_y
  beq cmru_left
  jsr collision_move_out_to_bottom
cmru_left:
  jsr collide_prep
  jsr collide_left_side
  lda collide_pixels_x
  beq cmru_done
  jsr collision_move_out_to_left
cmru_done:
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
  set_on_ground()

  lda maxp1gy
  sta p1gy
  lda maxp1gy+1
  sta p1gy+1
  lda #(200-p1height-40)
  //lda #214
  //lda #230
  sta p1ly
  bne updp1vpt_coll
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
  bne updp1vpt_coll
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
updp1vpt_coll:

updp1hp:
  // Update global position of character in level
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

  // stop character horizontal movement
  lda #0
  sta p1hva
  sta p1hva+1
  lda #hvzero
  sta p1hvi

  // update player position to furthest right position possible
  lda maxp1gx
  sta p1gx
  sta p1lx
  lda maxp1gx+1
  sta p1gx+1
  sta p1lx+1
  jmp updp1hpt
updp1hpneg:
  // move would have moved char to left of level
  // update position to far left of level and stop horiz movement
  lda #0
  sta p1gx
  sta p1gx+1
  sta p1lx
  sta p1lx+1
  sta p1hva
  sta p1hva+1

  lda #hvzero
  sta p1hvi
  jmp start_collision
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

start_collision:
  lda p1hva
  bmi collidel
  beq collidez
  // moving right
  lda p1vva
  bmi collideru
  beq colliderz
  // moving right and down
  jsr collision_moving_right_down
  jmp collided
collideru:
  // moving right and up
  jsr collision_moving_right_up
  jmp collided
colliderz:
  // moving right, vertical zero
  jsr collision_moving_right
  jmp collided
collidez:
  // not moving horiz
  lda p1vva
  bmi collidezu
  beq collidezz
  // not moving horiz, moving down
  jsr collision_moving_down
  jmp collided
collidezu:
  // not moving horiz, moving up
  jsr collision_moving_up
  jmp collided
collidel:
  // moving left
  lda p1vva
  bmi collidelu
  beq collidelz
  // moving left, moving down
  jsr collision_moving_left_down
  jmp collided
collidelu:
  // moving left, moving up
  jsr collision_moving_left_up
  jmp collided
collidelz:
  // moving left, not moving vert
  jsr collision_moving_left
  jmp collided
collidezz:
  // not moving horiz, not moving vert
  // jsr collision_not_moving
collided:
  jsr update_ground_status

  // now subtract the first column visible from the global position to get the local 
  // position relative to left side of screen, in pixel coordinates
  lda p1lx
  sec
  sbc SCR_first_visible_column_pixels
  //sta p1lx
  sta p1sx
  lda p1lx+1
  sbc SCR_first_visible_column_pixels+1
  //sta p1lx+1
  sta p1sx+1

  lda p1sx
  clc
  adc #31
  sta p1sx
  lda p1sx+1
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
  sta p1ly_prev
  clc
  adc #50
  sta p1sy
  lda p1ly+1
  sta p1ly_prev+1

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



updanim:
  lda animation_frame
  cmp #30
  bne updanim_20
  copy_sprite(sprite_image_0, SCR_sprite_data)
  jmp updanim_upd_animation_frame
updanim_20:
  lda animation_frame
  cmp #20
  bne updanim_10
  copy_sprite(sprite_image_1, SCR_sprite_data)
  jmp updanim_upd_animation_frame
updanim_10:
  lda animation_frame
  cmp #10
  bne updanim_00
  copy_sprite(sprite_image_2, SCR_sprite_data)
  jmp updanim_upd_animation_frame
updanim_00:
  lda animation_frame
  bne updanim_upd_animation_frame
  copy_sprite(sprite_image_3, SCR_sprite_data)
updanim_upd_animation_frame:
  dec animation_frame
  bne updanim_done
  lda #30
  sta animation_frame
updanim_done:
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

// gettime:
//   jsr $ffde
//   sty time+2
//   stx time+1
//   sta time
//   rts

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
p1lx_delta:  .byte 0,0
p1lx_prev:   .byte 0,0
p1lx2:       .byte 0,0
p1sx:        .byte 0,0
p1cx:        .byte 0,0
p1cx2:       .byte 0
p1vvi:       .byte 0
p1vva:       .byte 0,0
p1gy:        .byte 0,0
p1ly:        .byte 0,0 // 2 bytes due to a quirk in calculation
p1ly_delta:  .byte 0,0
p1ly_prev:   .byte 0,0
p1ly2:       .byte 0,0
p1sy:        .byte 0
p1cy:        .byte 0
p1cy2:       .byte 0
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

// TODO: move to zero page
current_buffer:  .byte 0
frame_phase:     .byte 0
frame_tick:      .byte 0
animation_frame: .byte 0

collide_pixels_x: .byte 0
collide_pixels_y: .byte 0

collision_metadata_row0: .byte 0,0,0
collision_metadata_row1: .byte 0,0,0
collision_metadata_row2: .byte 0,0,0
collision_metadata_row3: .byte 0,0,0

collision_column_even:   .byte 0
collision_row_even:      .byte 0
on_ground:               .byte 0

old_irq:                 .byte 0,0

sound_started:                .byte 0
melody_v1_index:              .byte 0
melody_v1_dur_left:           .byte 0
melody_v2_index:              .byte 0
melody_v2_dur_left:           .byte 0
melody_v3_index:              .byte 0
melody_v3_dur_left:           .byte 0
melody_frames_until_16th:     .byte 0

sound_effect_ticks_left:      .byte 0
sound_effect_sweep_freq_lo:   .byte 0
sound_effect_sweep_freq_hi:   .byte 0
sound_effect_sweep_ticks_left:      .byte 0

sound_effect_new_irq:    .byte 0
sound_effect_new_game_loop:   .byte 0
sound_effect_index_irq:       .byte 0
sound_effect_index_game_loop:

// sound effects table
// indices:
//   0 - jump
sound_effects_pulse_lo:
  .byte $00
sound_effects_pulse_hi:
  .byte $08
sound_effects_attack_decay:
  .byte $16
sound_effects_sustain_release:
  .byte $25
sound_effects_freq_lo:
  .byte $16
sound_effects_freq_hi:
  .byte $01
sound_effects_waveform:
  .byte %01000001
sound_effects_num_ticks:
  .byte 60
sound_effects_sweep_freq_lo:
  .byte $01
sound_effects_sweep_freq_hi:
  .byte $00
sound_effects_sweep_num_ticks:
  .byte 60
