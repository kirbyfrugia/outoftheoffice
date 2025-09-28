#import "reserved-mem.asm"
#import "const.asm"

.segment level1 [start=$3800]
#import "data/level1.asm"

.segment EnemyData [start=$5100]
#import "enemy-data.asm"

.segment Sprites1 [start=$0c00]
#import "data/spritesbatch1.asm"
.segment Sprites2 [start=$2000]
#import "data/spritesbatch2.asm"

// Note: max velocities can't be super large. Need to be less than 8 pixels
//   of movement per frame. Which would be a velocity of 71 (subpixels are included)
//   e.g. HV_ZERO-MAX_HV_LEFT must be less than 71. Should make it a lot less.
// Note also: the faster we move, the more expensive collision detection will be.
.const MAX_HV_LEFT      = 103  // max velocity going left
.const HV_ZERO          = 127 // horizontal velocity when not moving
.const MAX_HV_RIGHT     = 151 // max velocity going right
.const HORIZ_ACCEL_FAST = 3   // faster acceleration when switching directions
.const HORIZ_ACCEL_SLOW = 2   // slower acceleration, normal
.const HV_ZERO_LOWER    = HV_ZERO-HORIZ_ACCEL_FAST-1 // anything between this and HV_ZERO is considered stopped
.const HV_ZERO_UPPER    = HV_ZERO+HORIZ_ACCEL_FAST+1 // anything between HV_ZERO and this considered stopped

.const MAX_VV_UP        = 103  // vertical velocity when moving up at full speed
.const VV_ZERO          = 127 // vertical velocity when not moving
.const MAX_VV_DOWN      = 151 // vertical velocity when moving down at full speed
.const FALL_ACCEL       = 3   // acceleration rate when falling
.const RISE_ACCEL       = 2   // acceleration rate when rising
.const VV_BOUNCE        = 118 // vertical velocity when bouncing off an enemy

.disk [filename="office.d64", name="OFFICE", id="O1" ] {
  [name="OFFICE", type="prg", segments="StubBasic"],
  [name="SPRITES1", type="prg", segments="Sprites1"],
  [name="SPRITES2", type="prg", segments="Sprites2"],
  [name="LEVEL1", type="prg", segments="level1"],
  [name="GAME", type="prg", segments="Game"],
}

.segment StubBasic [start=$0801]
// --------------------------------------
// BASIC loader stub
// --------------------------------------

// A BASIC line: 10 SYS2061
.word nextLine      // pointer to next BASIC line
.word 10            // line number
.byte $9e           // BASIC token for SYS
.text "2061"        // ASCII for SYS address
.byte 0             // end of BASIC line
nextLine:
.word 0             // end of program marker

// --------------------------------------
// Stub routine at $080d (2061)
// --------------------------------------
// .segment StubAsm [start=$080d]
.pc = $080d
stub:
  sei
  lda $01
  and #%11111000      // clear LORAM/HIRAM/CHAREN bits
  ora #%00000110      // LORAM=0 (BASIC out), HIRAM=1 (keep KERNAL), CHAREN=1 (keep I/O)
  sta $01
  cli

  lda #0
  sta BG_COLOR0
  sta BORDER_COLOR

  jsr $e544                    // kernal clear screen

  lda #12   // L
  sta SCREEN_MEM1+12*40+15
  lda #15   // O
  sta SCREEN_MEM1+12*40+16
  lda #1    // A
  sta SCREEN_MEM1+12*40+17
  lda #4    // D
  sta SCREEN_MEM1+12*40+18
  lda #9    // I
  sta SCREEN_MEM1+12*40+19
  lda #14   // N
  sta SCREEN_MEM1+12*40+20
  lda #7    // G
  sta SCREEN_MEM1+12*40+21
  lda #46   // .
  sta SCREEN_MEM1+12*40+22
  sta SCREEN_MEM1+12*40+23
  sta SCREEN_MEM1+12*40+24

  // load the game
  lda #15                      // logical file number
  ldx #8                       // device number
  ldy #0                       // secondary address is 0, should load to location "start"
  jsr $ffba                    // setlfs
  lda #(gamename_end-gamename) // length of filename
  ldx #<gamename               // pointer to filename low byte
  ldy #>gamename               // pointer to filename high byte
  jsr $ffbd                    // setnam
  
  lda #0
  ldx #<start
  ldy #>start
  jsr $ffd5                    // load
  sta $fb
  stx $fc
  sty $fd

  jmp start                    // jump into the game

// data area
gamename:
  .text "GAME"
gamename_end:
fload_results:
  .byte 0, 0

.segment Game [start=$8000]
start:
  jmp init

#import "data.asm"
#import "utils.asm"
#import "sound-data.asm"
#import "data/song-kirby.asm"
// #import "data/song-devils-dream.asm"
#import "screen.asm"
#import "enemy-types.asm"
#import "data/level1-enemies.asm"
#import "data/level1-jobs.asm"

irq_dispatch:
  lda next_irq
  sta current_irq
  cmp #RASTER_HUD
  beq call_hud
  cmp #RASTER_HUD_DONE
  beq call_hud_done
  cmp #RASTER_BUFFER_SWAP
  beq call_buffer
  jmp irq_done // should never happen
call_buffer:
  jsr irq_music
  jsr upd_sound_effects
  lda frame_phase
  eor #%00000001
  sta frame_phase
  beq call_buffer_next_frame
  jsr irq_buffer_swap
  jsr irq_color_upper_shift
  jsr irq_color_lower_shift
call_buffer_next_frame:
  lda #RASTER_HUD
  sta next_irq
  sta VIC_RW_RASTER
  lda #1
  sta frame_tick
  jmp irq_done
call_hud:
  lda #COLOR_HUD_BG
  sta BG_COLOR0
  lda VIC_HCONTROL_REG
  and #%11010000 // set no scroll
  sta VIC_HCONTROL_REG
  lda #RASTER_HUD_DONE
  sta next_irq
  sta VIC_RW_RASTER
  jmp irq_done
call_hud_done:
  lda #COLOR_BG
  sta BG_COLOR0
  lda VIC_HCONTROL_REG
  and #%11010000
  ora SCR_scroll_register
  sta VIC_HCONTROL_REG
  lda #RASTER_BUFFER_SWAP
  sta next_irq
  sta VIC_RW_RASTER
  jmp irq_done
irq_done:
  asl VIC_IRQ_FLAG

  jmp $ea81

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

irq_music:
  lda sound_started
  bne sound_is_started
  jmp music_done
sound_is_started:
music:
  // now let's deal with the music
  dec melody_frames_until_16th
  beq on_16th
  jmp music_done
on_16th:
  lda #melody_tempo
  sta melody_frames_until_16th
  voice_handler(VOICE1_CONTROL, VOICE1_HF, VOICE1_LF, melody_v1_control, melody_v1_dur_left, melody_v1_index, melody_v1, melody_v1_end, melody_v1_done)
melody_v1_done:
  voice_handler(VOICE2_CONTROL, VOICE2_HF, VOICE2_LF, melody_v2_control, melody_v2_dur_left, melody_v2_index, melody_v2, melody_v2_end, melody_v2_done)
melody_v2_done:
music_done:
  rts

.macro hwscroll_left(scroll_amount) {
  ldx scroll_amount
  beq hwscroll_left_noscroll
hwscroll_left_loop:
  lda SCR_scroll_register
  sec
  sbc #1
  and #%00000111
  sta SCR_scroll_register
  lda VIC_HCONTROL_REG
  and #%11010000
  ora SCR_scroll_register
  sta VIC_HCONTROL_REG
  dex
  stx scroll_amount
  bne hwscroll_left_loop
hwscroll_left_noscroll:
}

.macro hwscroll_right(scroll_amount) {
  ldx scroll_amount
  beq hwscroll_right_noscroll
hwscroll_right_loop:
  lda SCR_scroll_register
  clc
  adc #1
  and #%00000111
  sta SCR_scroll_register
  lda VIC_HCONTROL_REG
  and #%11010000
  ora SCR_scroll_register
  sta VIC_HCONTROL_REG
  dex
  stx scroll_amount
  bne hwscroll_right_loop
hwscroll_right_noscroll:
}

irq_buffer_swap:
  // first let's scroll the hw register until we need to swap buffers
  hwscroll_left(SCR_scroll_left_amounts_pre)
  hwscroll_right(SCR_scroll_right_amounts_pre)

  // now do the actual buffer swap  
  lda pending_buffer_swap
  beq irq_buffer_swapd
  lda SCR_buffer_flag
  beq sb_screen0800

  lda VIC_MEM_CONTROL_REG
  and #%00001111
  ora #%00010000 // screen location 1024, $0400
  sta VIC_MEM_CONTROL_REG
  lda #0
  sta SCR_buffer_flag
  beq swap_buffers_swapped
sb_screen0800:
  lda VIC_MEM_CONTROL_REG
  and #%00001111
  ora #%00100000 // screen location 2048, $0800
  sta VIC_MEM_CONTROL_REG
  lda #1
  sta SCR_buffer_flag
swap_buffers_swapped:
  // now let's do any scrolling still needed AFTER buffer swapping
  hwscroll_left(SCR_scroll_left_amounts_post)
  hwscroll_right(SCR_scroll_right_amounts_post)
  lda #0
  sta pending_buffer_swap
irq_buffer_swapd:
  rts

irq_color_upper_shift:
  lda pending_color_upper_swap
  beq irq_color_upper_shiftd
  lda SCR_direction
  bne irq_color_upper_shift_right
  jsr SCR_move_color_left_upper
  jmp irq_color_upper_shiftd
irq_color_upper_shift_right:
  jsr SCR_move_color_right_upper
irq_color_upper_shiftd:
  lda #0
  sta pending_color_upper_swap
  rts

irq_color_lower_shift:
  lda pending_color_lower_swap
  beq irq_color_lower_shiftd
  lda SCR_direction
  bne irq_color_lower_shift_right
  jsr SCR_move_color_left_lower
  jmp irq_color_lower_shiftd
irq_color_lower_shift_right:
  jsr SCR_move_color_right_lower
irq_color_lower_shiftd:
  lda #0
  sta pending_color_lower_swap
  rts

// TODO: remove for production build, only used during test
update_max_raster_line:
  lda VIC_VCONTROL_REG
  and #%10000000
  lsr
  lsr
  lsr
  lsr
  lsr
  lsr
  lsr
  sta raster_line+1
  cmp max_raster_line+1
  bcc update_max_raster_lined
  lda VIC_RW_RASTER
  sta raster_line
  cmp max_raster_line
  bcc update_max_raster_lined
  sta max_raster_line
  lda raster_line+1
  sta max_raster_line+1
update_max_raster_lined:
  rts

init:
  lda #3
  sta num_lives

  jsr disable_irqs
  jsr initsound

  jsr SCR_load_sprite_sheets

  lda #level1_MAP_WID
  sta SCR_tile_level_width
  jsr SCR_loadmap
  jsr init_screen_settings

  jsr load_sprites
  jsr restart_level

game_loop:
  lda frame_tick
  beq game_loop
  lda #0
  sta frame_tick

  jsr inkbd
  jsr injs

  lda frame_phase
  bne odd_frame
even_frame:
  // store old position for collision detection
  lda p1gy+1
  sta p1gy_old+1
  sta p1gy_old_feet_screenchars+1

  lda p1gy
  sta p1gy_old
  sta p1gy_old_feet_screenchars

  // remove subpixels
  lsr p1gy_old_feet_screenchars+1
  ror
  lsr p1gy_old_feet_screenchars+1
  ror
  lsr p1gy_old_feet_screenchars+1
  ror

  clc
  adc #P1_COLLISION_Y3
  sta p1gy_old_feet_screenchars
  lda p1gy_old_feet_screenchars+1
  adc #0
  sta p1gy_old_feet_screenchars+1

  // convert to screen chars
  lsr
  ror p1gy_old_feet_screenchars
  lsr
  ror p1gy_old_feet_screenchars
  lsr
  ror p1gy_old_feet_screenchars
  sta p1gy_old_feet_screenchars+1

  // collision detection is really expensive, so we do all the positioning
  // on the even frame and all the screen updates on the odd.
  jsr updp1hv
  jsr updp1vv
  jsr updp1p
  jsr update_on_ground
  jsr upd_enemies_pos
  jmp every_frame

odd_frame:
  // we only update the back buffer after we try to move
  // the player sprite
  lda #0
  sta SCR_buffer_ready

// wait until the buffer has been swapped from last time
// in case it hasn't yet, just in case.
buffer_wait:
  lda pending_buffer_swap
  bne buffer_wait

  lda p1sy
  sta p1sy_old
  lda p1sy+1
  sta p1sy_old+1

  // jsr update_on_ground

  // if here, any screen buffer updates from previous frame
  // have completed.
  jsr upd_enemies_sprites
  jsr updp1p_sprite
  jsr upd_enemies_buffer

  jsr enemy_collisions_kill
  jsr updanim
  // jsr hud

  lda SCR_buffer_ready
  sta pending_buffer_swap
  sta pending_color_upper_swap
  sta pending_color_lower_swap

  // jsr update_max_raster_line
  jsr log
every_frame:
  jmp game_loop


init_screen_settings:
  // turn on multiclr char mode
  // lda VIC_HCONTROL_REG
  // ora #%00010000
  // sta VIC_HCONTROL_REG

  // use our in-memory charset
  lda VIC_MEM_CONTROL_REG
  and #%11110000
  ora #%00001110 // $3800-3fff
  sta VIC_MEM_CONTROL_REG

  // background color
  lda #COLOR_BG
  sta BG_COLOR0

  lda #COLOR_BORDER
  sta BORDER_COLOR
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

  lda #0
  sta sound_effect_ready
  sta sound_effect_index
  sta melody_v1_index
  sta melody_v1_dur_left
  sta melody_v2_index
  sta melody_v2_dur_left
  sta current_sound_effect_sweep_adder_lo
  sta current_sound_effect_sweep_adder_hi
  sta sound_started
  lda #melody_tempo
  sta melody_frames_until_16th
  rts

restart_player_velocity:
  lda #0
  sta p1hva
  sta p1hva+1
  sta p1vva
  sta p1vva+1

  lda #HV_ZERO
  sta p1hvi

  lda #VV_ZERO
  sta p1vvi

  rts

restart_player_position:
  lda #0
  sta p1gx+1

  // initialize player position with zero fractional
  lda #P1_STARTX
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  rol
  rol p1gx+1
  and #%11111000
  sta p1gx

  lda #0
  sta p1gy+1

  lda #P1_STARTY
  clc
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  rol
  rol p1gy+1
  sec
  sbc #1 // subtract a subpixel so we start one subpixel above the ground
  sta p1gy

  lda #1
  sta on_ground

  rts

restart_player:
  jsr restart_player_velocity
  jsr restart_player_position
  jsr restart_player_animation
  rts

restart_player_animation:
  lda #%01000000 // facing right, not moving or jumping
  sta player_animation_flag
  rts

restart_enemies:
  jsr init_level_enemies

  lda #0
  sta enemies_buffer_min

  lda enemies_count
  cmp #MAX_ENEMY_BUFFER_SIZE
  bcc restart_enemies_less_than_max
  // if here, there are at least as many enemies as max buffer size
  lda #MAX_ENEMY_BUFFER_SIZE
restart_enemies_less_than_max:
  sta enemies_buffer_max

  rts

restart_input:
  lda #$ff
  sta ebl
  sta ebr
  sta ebu
  sta ebd
  sta ebp
  rts

disable_irqs:
  // disable interrupts
  sei

  // switch off cia interrupts
  lda #$7f
  sta $dc0d
  sta $dd0d

  // clear any pending interrupts from CIA-1/2
  lda $dc0d
  lda $dd0d

  // disable raster interrupt source
  lda #%11111110
  and VIC_IRQ_MASK
  sta VIC_IRQ_MASK

  // clear high raster bit
  lda VIC_VCONTROL_REG
  and #%01111111
  sta VIC_VCONTROL_REG

  // clear any pending raster interrupts
  lda #$0f
  sta VIC_IRQ_FLAG
  cli
  rts

enable_irqs:
  sei
  // set interrupt handling routine
  lda #<irq_dispatch
  sta $0314
  lda #>irq_dispatch
  sta $0315

  // raster line where interrupt will occur
  lda #RASTER_BUFFER_SWAP
  sta VIC_RW_RASTER
  sta next_irq

  // enable raster interrupt source
  lda #%00000001
  sta VIC_IRQ_MASK

  cli
  rts

// delays by a number of rasters
// inputs:
//   x - number of rasters to wait
// modifies: x and y
delay_rasters:
delay_rasters_outer_loop:
  lda VIC_RW_RASTER
  cmp #$fa
  beq delay_rasters_inner
  bne delay_rasters_outer_loop
  // do some work just to delay a bit and get past the raster line
delay_rasters_inner:
  ldy #12
delay_rasters_inner_loop:
  nop
  nop
  nop
  dey
  bpl delay_rasters_inner_loop
  dex
  bne delay_rasters_outer_loop
  rts

show_lives:
  // set the screen background
  lda #COLOR_SWIPE
  sta BG_COLOR0

  // display how many lives we have remaining.
  // Show the player sprite near the center of the screen.
  .var screen_centerx = (320 / 2)
  .var playerx        = 31 + screen_centerx - (p1width / 2) - 16
  .var screen_centery = (200 / 2)
  .var playery        = 50 + 12*8 - (p1height / 2) + 4
  //.var playery        = 50 + screen_centery - (p1height / 2)

  // player facing right sprite index
  lda #P1_FACING_RIGHT_OFFSET
  sta SPRITE_PTR_BASE_FB+0 // 1024 buffer
  sta SPRITE_PTR_BASE_BB+0 // 2048 buffer

  lda #playerx
  sta SPRITE_XPOS_BASE+0

  lda #%00000000
  sta SPRITE_MSB

  lda #playery
  sta SPRITE_YPOS_BASE+0

  lda #%00000001
  sta SPRITE_ENABLE

  lda #24 // letter x
  sta SCREEN_MEM1+12*40+20
  lda #48
  clc
  adc num_lives
  sta SCREEN_MEM1+12*40+20+2

  lda #1
  sta COLOR_MEM+12*40+20
  sta COLOR_MEM+12*40+20+2

  ldx #180
  jsr delay_rasters

  // hide player sprite again
  lda #%00000000
  sta SPRITE_ENABLE

  // cover up number of lives
  lda #CHAR_FILLED
  sta SCREEN_MEM1+12*40+20
  sta SCREEN_MEM1+12*40+20+2

  lda #COLOR_SWIPE
  sta COLOR_MEM+12*40+20
  sta COLOR_MEM+12*40+20+2

  lda #COLOR_BG
  sta BG_COLOR0

  rts

restart_level:
  jsr disable_irqs

  sei
  lda #0
  sta pending_buffer_swap
  sta frame_phase
  sta current_buffer
  sta SCR_buffer_flag

  lda VIC_MEM_CONTROL_REG
  and #%00001111
  ora #%00010000 // screen location 1024, $0400
  sta VIC_MEM_CONTROL_REG

  jsr stop_sound

  cli

  lda #30
  sta animation_frame

  // disable all sprites
  lda #%00000000
  sta SPRITE_ENABLE

  jsr clear_screen
  jsr clear_hud
  jsr SCR_init_screen
  jsr show_lives
  jsr SCR_draw_screen  // draw to back buffer (2048)
  jsr enable_irqs

  jsr SCR_swipe_screen // Swipe from 2048 to 1024

  jsr restart_player
  jsr restart_enemies
  jsr restart_input
  jsr restart_map
  
  jsr load_sprites

  // enable player
  lda #%00000001
  sta SPRITE_ENABLE

  jsr start_sound

  jsr restart_hud

  rts

player_died:
  lda #P1_DEAD
  sta SPRITE_PTR_BASE_FB+0
  sta SPRITE_PTR_BASE_BB+0

  play_sound(3)

  ldx #30
  jsr delay_rasters

  dec num_lives
  jsr restart_level
  rts

stop_sound:
  lda #0
  sta sound_started

  // stop any currently playing music and sound effects
  lda VOICE1_CONTROL
  and #%11111110
  sta VOICE1_CONTROL

  lda VOICE2_CONTROL
  and #%11111110
  sta VOICE2_CONTROL

  lda VOICE3_CONTROL
  and #%11111110
  sta VOICE3_CONTROL
  rts

start_sound:

  // on init, move to end of song with 1 16th notes remaining
  // so that we loop back to start in the irq

  lda #(melody_v1_end - melody_v1)
  sta melody_v1_index
  lda #(melody_v2_end - melody_v2)
  sta melody_v2_index
  // lda #(melody_v3_end - melody_v3)
  // sta melody_v3_index

  lda #0
  sta current_sound_effect_ticks_left
  sta current_sound_effect_sweep_ticks_left
  lda #1
  sta melody_v1_dur_left
  sta melody_v2_dur_left
  // sta melody_v3_dur_left
  sta sound_started
  rts

load_sprites:
  // set sprite multi colors
  lda #sprmc0
  sta SPRITE_MC0
  lda #sprmc1
  sta SPRITE_MC1

  // player sprite pointer
  ldx #(SPRITE_PTR_FIRST_B1+0)
  stx SPRITE_PTR_BASE_FB // front buffer
  stx SPRITE_PTR_BASE_BB // back buffer

  lda #%00000001
  sta SPRITE_MC_MODE

  ldx #0
  lda spritesbatch1_spriteset_attrib_data, x
  sta SPRITE_COLOR_BASE+0

  lda #P1_STARTX
  clc
  adc #31
  sta SPRITE_XPOS_BASE+0

  lda #%00000000
  sta SPRITE_MSB

  lda #P1_STARTY
  clc
  adc #50
  sta SPRITE_YPOS_BASE+0

  rts


loadmap:
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
  // shift 3 more to the left to account for the fractional portion
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1

  // grab the pixel value here
  lda maxp1gx
  sta maxp1gx_px
  lda maxp1gx+1
  sta maxp1gx_px+1

  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  rol maxp1gx
  rol maxp1gx+1
  lda maxp1gx
  and #%11000000
  sta maxp1gx

  lda #(200-p1height-40+1)
  sta maxp1gy
  sta maxp1gy_px
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

restart_map:

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
  rts

clear_hud:
  ldx #39
clear_hud_loop:
  lda #0
  sta SCREEN_MEM1+21*40, x
  sta SCREEN_MEM2+21*40, x
  sta SCREEN_MEM1+22*40, x
  sta SCREEN_MEM2+22*40, x
  sta SCREEN_MEM1+23*40, x
  sta SCREEN_MEM2+23*40, x
  sta SCREEN_MEM1+24*40, x
  sta SCREEN_MEM2+24*40, x
  lda #COLOR_HUD_BG
  sta COLOR_MEM+21*40, x
  sta COLOR_MEM+22*40, x
  sta COLOR_MEM+23*40, x
  sta COLOR_MEM+24*40, x
  dex
  bpl clear_hud_loop
  rts

restart_hud:
  ldx #39
restart_hud_fgclr_loop:
  lda #COLOR_HUD_TITLE
  sta HUD_ROW_0_CLR, X
  lda #COLOR_HUD_TEXT
  sta HUD_ROW_1_CLR, X
  lda #COLOR_HUD_TEXT
  sta HUD_ROW_2_CLR, X
  dex
  bpl restart_hud_fgclr_loop

hud_render_time_title:
  lda #20   // T
  sta 1905
  sta 2929
  lda #9    // I
  sta 1906
  sta 2930
  lda #13   // M
  sta 1907
  sta 2931
  lda #5    // E
  sta 1908
  sta 2932

hud_render_jobs_title:
  lda #10   // J
  sta 1910
  sta 2934
  lda #15   // O
  sta 1911
  sta 2935
  lda #2    // B
  sta 1912
  sta 2936

hud_render_parts_title:
  lda #16   // P
  sta 1931
  sta 2955
  lda #1    // A
  sta 1932
  sta 2956
  lda #18   // R
  sta 1933
  sta 2957
  lda #20   // T
  sta 1934
  sta 2958
  lda #19   // S
  sta 1935
  sta 2959

hud_render_score_title:
  lda #19   // S
  sta 1937
  sta 2961
  lda #3    // C
  sta 1938
  sta 2962
  lda #15   // O
  sta 1939
  sta 2963
  lda #18   // R
  sta 1940
  sta 2964
  lda #5    // E
  sta 1941
  sta 2965
  rts

// modifies: x, y, a
// inputs:
//   x - job id
//   zpb0/zpb1 - front buffer screen location to print job to, lo/hi
//   zpb2/zpb3 - back buffer screen location to print job to, lo/hi
hud_show_job_title:
  lda jobs_title_lo, x
  sta zpb4
  lda jobs_title_hi, x
  sta zpb5
  ldy #0
hud_show_job_loop:
  lda (zpb4), y
  sta (zpb0), y
  sta (zpb2), y
  iny
  tya
  cmp jobs_title_len, x
  bne hud_show_job_loop
  rts

hud:
  // jobs area
  lda #7 // yellow
  sta HUD_ROW_1_CLR+6
  lda #71 // warning sign
  sta HUD_ROW_1_FB+6
  sta HUD_ROW_1_BB+6

  lda #<HUD_ROW_1_FB
  clc
  adc #7
  sta zpb0
  sta zpb2
  lda #>HUD_ROW_1_FB
  adc #0
  sta zpb1
  lda #>HUD_ROW_1_BB
  adc #0
  sta zpb3
  ldx #0 // job 0
  jsr hud_show_job_title

  lda #4 // yellow
  sta HUD_ROW_2_CLR+6
  lda #70 // ink drop
  sta HUD_ROW_2_FB+6
  sta HUD_ROW_2_BB+6

  lda #<HUD_ROW_2_FB
  clc
  adc #7
  sta zpb0
  sta zpb2
  lda #>HUD_ROW_2_FB
  adc #0
  sta zpb1
  lda #>HUD_ROW_2_BB
  adc #0
  sta zpb3
  ldx #1 // job 1
  jsr hud_show_job_title

  // supplies area
  lda #4 // purple
  sta HUD_ROW_1_CLR+27
  lda #70 // ink drop
  sta HUD_ROW_1_FB+27
  sta HUD_ROW_1_BB+27

  rts

// log_posx:
//   lda p1gx+1
//   jsr loghexit
//   iny
//   lda p1gx
//   jsr loghexit

//   iny
//   iny
//   lda p1lx+1
//   jsr loghexit
//   iny
//   lda p1lx
//   jsr loghexit

//   iny
//   iny
//   lda p1sx+1
//   jsr loghexit
//   iny
//   lda p1sx
//   jsr loghexit

//   iny
//   iny
//   lda p1hva+1
//   jsr loghexit
//   iny
//   lda p1hva
//   jsr loghexit

//   iny
//   iny
//   lda p1gx_coll+1
//   jsr loghexit
//   iny
//   lda p1gx_coll
//   jsr loghexit

//   iny
//   iny
//   lda num_collision_tests
//   jsr loghexit

//   rts

// log_screen:
//   lda SCR_first_visible_column+1
//   jsr loghexit
//   iny
//   lda SCR_first_visible_column
//   jsr loghexit
//   iny
//   lda #43
//   sta (zpb0),y
//   iny
//   lda SCR_scroll_offset
//   jsr loghexit
//   iny
//   iny
//   lda SCR_scroll_register
//   jsr loghexit
//   iny
//   iny
//   lda VIC_HCONTROL_REG
//   jsr loghexit
//   iny
//   iny
//   lda SCR_scroll_out
//   jsr loghexit

//   iny
//   iny
//   lda max_raster_line+1
//   jsr loghexit
//   iny
//   lda max_raster_line
//   jsr loghexit
  
//   iny
//   iny
//   lda SCR_first_column_beyond_screen_pixels+1
//   jsr loghexit
//   iny
//   lda SCR_first_column_beyond_screen_pixels
//   jsr loghexit
//   rts

log_posy:
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
  lda on_ground
  jsr loghexit

  rts

// log_collision:
//   lda collide_pixels_x
//   jsr loghexit
//   iny
//   lda collide_pixels_y
//   jsr loghexit

//   iny
//   iny
//   lda p1cx2
//   jsr loghexit
//   iny
//   lda p1cy2
//   jsr loghexit

//   iny
//   iny
//   lda on_ground
//   jsr loghexit

//   iny
//   iny
//   lda collision_row_even
//   jsr loghexit
//   iny
//   lda collision_column_even
//   jsr loghexit

//   ldy #10
//   ldx #0
// log_line_collision_loop:
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
//   bne log_line_collision_loop
//   rts

// log_melody:
//   lda melody_frames_until_16th
//   jsr loghexit
//   iny
//   iny
//   lda melody_v1_index
//   jsr loghexit
//   iny
//   iny
//   lda melody_v1_dur_left
//   jsr loghexit
//   iny
//   iny
//   lda melody_v2_index
//   jsr loghexit
//   iny
//   iny
//   lda melody_v2_dur_left
//   jsr loghexit
//   iny
//   iny
//   lda current_sound_effect_ticks_left
//   jsr loghexit
//   iny
//   iny
//   lda current_sound_effect_sweep_ticks_left
//   jsr loghexit
//   iny
//   iny
//   lda VOICE3_LF
//   jsr loghexit
//   iny
//   iny
//   lda VOICE3_HF
//   jsr loghexit
//   rts

log_enemies:
  iny
  iny
  lda enemies_buffer_min
  jsr loghexit
  iny
  lda enemies_buffer_max
  jsr loghexit

  iny
  iny
  lda p1sx+1
  jsr loghexit
  iny
  lda p1sx
  clc
  adc #P1_COLLISION_OFFSETY
  adc #P1_COLLISION_HEIGHT
  jsr loghexit

  iny
  iny
  lda enemy_collided_temp
  jsr loghexit

  iny
  iny
  lda enemy_kills
  jsr loghexit

  rts

// TODO: dont assemble for release
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
  // jsr log_screen
  // jsr log_posx
  jsr log_posy
  // jsr log_enemies
  // jsr log_screen
  // jsr log_melody

  
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
  // jsr log_posy
  // jsr log_collision


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


  rts

// How player velocity and positioning works.
// Velocity
//   There are two velocities: indexed velocity and actual velocity.
//     indexed velocity is a value from 0 to 255, unsigned.
//       0 is moving top speed to the left, 255 is top to the right, 127 is zero speed.
//     actual velocity is a signed value calculated by subtracting 127 from the indexed velocity.
//       the actual velocity is used when updating the player's position.
//   Player input determines target indexed velocity, which is either 0,127, or 255.
//      Note: technically it's MAX_HV_LEFT, MAX_HV_RIGHT, etc
// Acceleration
//   If the player is moving one direction and is changing directions, then accel/decel
//     rate is higher.
// Position 
//   Player position is calculated by adding the actual velocity to current position.
//     Global position is a 16 bit number stored in p1gx/+1.
// The 3 least significant bits of the actual velocity and position are fractional
//   and are rotated out when updating the sprite's actual position on the screen.
//   This allows smoother and smaller movement, acceleration, etc.
// Key variables:
//   p1hvi        - horiz vel,indexed
//   p1hva        - horiz vel,actual
//   p1gx         - global xpos, including fractional portion
//   p1gx_pixels  - global xpos, excluding fractional portion
//   p1lx         - global xpos, minus fractional portion
//   p1sx         - sprite xpos, pixel coordinates, includes border
//   p1vvi        - vert vel,indexed
//   p1vva        - vert vel,actual
//   p1gy         - global ypos
//   p1ly         - global ypos, minus fractional portion
//   p1hvt        - horiz target vel
//   p1vvt        - vert target vel
//   MAX_HV_LEFT  - max velocity when moving left
//   MAX_HV_RIGHT - max velocity when moving right


updp1hv:
  lda ebl
  and #%00000011
  cmp #%00000011
  bne updp1hvl
  lda ebr
  and #%00000011
  cmp #%00000011
  bne updp1hvr
  lda #HV_ZERO
  sta p1hvt
  // if we want to stop moving, let's see if we're
  // close to stopping. If so, just stop to deal
  // with being off by minor amounts when updating our speed
  lda p1hvi
  cmp #HV_ZERO_LOWER
  bcc updp1htvd // we're more than our accel speed away from stopped, slow side
  cmp #HV_ZERO_UPPER
  bcs updp1htvd // we're more than our accel speed away from stopped, fast side

  // just set our speed to zero since we were close enough to stopped.
  // fixes any off by a little errors
  lda #HV_ZERO
  sta p1hvi
  bne updp1htvd
updp1hv_maybe_stopped:
updp1hvl:
  // moving left, target full speed left
  lda player_animation_flag
  and #%10111111  // moving left (from an animation perspective)
  sta player_animation_flag
  lda #MAX_HV_LEFT
  sta p1hvt
  bne updp1htvd
updp1hvr:
  // moving right, target full speed right
  lda player_animation_flag
  ora #%01000000  // moving right (from an animation perspective)
  sta player_animation_flag
  lda #MAX_HV_RIGHT
  sta p1hvt
updp1htvd:
  // if here, we have calculated our target velocity
  lda p1hvi
  cmp p1hvt
  beq updp1hv_at_target_velocity      // already at target speed, nothing to do
  bcc updp1h_accel_right              // current velocity less than target, so want to be going towards right
  // if here, want to be going towards left
  cmp #HV_ZERO            
  bcs updp1h_moving_right_accel_left  // still moving right, but wanting to go left
  // if here, already moving left and want to keep going left
  pha
  lda player_animation_flag
  and #%11101111 // not turning
  ora #%00100000 // moving horizontally
  sta player_animation_flag
  pla
  sec
  sbc #HORIZ_ACCEL_SLOW
  sta p1hvi
  bne updp1hvd
updp1h_moving_right_accel_left:
  pha
  lda player_animation_flag
  ora #%00110000 // moving horizontally, turning
  sta player_animation_flag
  pla
  sec
  sbc #HORIZ_ACCEL_FAST
  sta p1hvi
  bne updp1hvd
updp1h_accel_right:
  cmp #HV_ZERO
  bcc updp1h_moving_left_accel_right  // want to go right, but moving left
  // if here, already moving right and want to keep going right
  pha
  lda player_animation_flag
  and #%11101111 // not turning
  ora #%00100000 // moving horizontally
  sta player_animation_flag
  pla
  clc
  adc #HORIZ_ACCEL_SLOW
  sta p1hvi
  bne updp1hvd
updp1h_moving_left_accel_right:
  pha
  lda player_animation_flag
  ora #%00110000 // moving horizontally, turning
  sta player_animation_flag
  pla
  clc
  adc #HORIZ_ACCEL_FAST
  sta p1hvi
  jmp updp1hvd
updp1hv_at_target_velocity:
  lda p1hvi
  cmp #HV_ZERO
  bne updp1hvd
  // if here, at target velocity, not moving
  pha
  lda player_animation_flag
  and #%11011111 // standing still horizontally
  sta player_animation_flag
  pla
updp1hvd:
  lda p1hvi
  cmp #MAX_HV_LEFT
  bcc updp1hvd_cap_left
  cmp #MAX_HV_RIGHT
  bcc updp1hvd_nocap
  // if here, moving too fast to the right
  lda #MAX_HV_RIGHT
  sta p1hvi
  bne updp1hvd_nocap
updp1hvd_cap_left:
  // if here, moving too fast left
  lda #MAX_HV_LEFT
  sta p1hvi
updp1hvd_nocap:
  lda p1hvi
  sec
  sbc #HV_ZERO
  sta p1hva
  lda p1hva+1
  sbc #0
  sta p1hva+1
  rts

updp1vv:
  lda on_ground
  beq updp1vv_not_on_ground

  // if  here, we are on the ground.

  // only jump on new button presses
  // if either of last two scans of joystick button are a zero, jump
  lda ebp
  and #%00000011
  cmp #%00000011
  beq updp1vv_on_ground_no_jump

  lda player_animation_flag
  ora #%10000000 // jumping
  sta player_animation_flag

  // if here, jumping
  lda #0
  sta on_ground
  // Play jump sound effect
  play_sound(0)

  // When jumping, actual velocity is immediately set to max upwards velocity
  // And target is set to max falling velocity
  lda #MAX_VV_UP
  sta p1vvi
  jmp updp1vvd_nocap
updp1vv_on_ground_no_jump:
  // on ground, not jumping
  lda player_animation_flag
  and #%01111111 // not jumping
  sta player_animation_flag

  lda #VV_ZERO
  sta p1vvi
  sta p1vvt
  bne updp1vtvd
updp1vv_not_on_ground:
  // if not on the ground and not starting a jump,
  // target velocity is always max falling speed
  lda #MAX_VV_DOWN
  sta p1vvt
updp1vtvd:
  // target velocity calculated, calculate new actual
  lda p1vvi             // current velocity
  cmp p1vvt
  beq updp1vvd_nocap    // at target velocity already, no need to accelerate or decelerate
  cmp #VV_ZERO          // this is the peak of the jump
  bcc udp1vrising       // not yet at peak of jump, so still rising
  // if here, we're at or above the peak of the jump, so we're falling
  clc
  adc #FALL_ACCEL
  sta p1vvi
  jmp updp1vvd
udp1vrising:
  clc
  adc #RISE_ACCEL
  sta p1vvi
updp1vvd:
  // if here, we are past our peak fall rate, so cap it
  lda p1vvi
  cmp #MAX_VV_DOWN
  bcc updp1vvd_nocap
  beq updp1vvd_nocap
  lda #MAX_VV_DOWN
  sta p1vvi        
updp1vvd_nocap:
  sec
  sbc #VV_ZERO
  sta p1vva
  lda p1vva+1
  sbc #0
  sta p1vva+1
  rts

update_on_ground:
  lda #SCR_COLLISION_MASK_TOP
  sta collision_mask

  lda p1gx
  sta p1gx_coll
  lda p1gx+1
  sta p1gx_coll+1

  lda p1gy
  clc
  adc #1 // check 1 subpixel down for collision detect
  sta p1gy_coll
  lda p1gy+1
  adc #0
  sta p1gy_coll+1

  jsr test_player_collisions
  beq is_not_on_ground

is_on_ground:
  lda #1
  sta on_ground
  bne update_on_groundd
is_not_on_ground:
  lda #0
  sta on_ground
update_on_groundd:
  rts


// Filters collisions under the following circumstance:
// 1. It's a top-only collision and it's not the player's feet.
// 2. It's a top-only collision, it is the player's feet, but the
//    player didn't cross the top of the tilechar in this exact frame
// inputs:
//   A - results of the collision test before
//   p1gy_coll/+1 - assumes already in screen char coords
// outputs:
//   A - nonzero if no collision, zero if collision
filter_collision:
  pha

  // check if we're doing a top only collision
  lda collided_char_attribs
  cmp #SCR_COLLISION_MASK_TOP
  bne filter_collision_unfiltered // no filtering unless it's a top only tilechar

  // check if we're testing the feet
  lda p1gy_offset
  cmp #P1_COLLISION_Y3
  bne filter_collision_filtered // filter if not the feet

  // Now check if the player crossed a character threshold while
  // moving down.

  // If the old tilechar y is < new, don't filter out this collision
  lda p1gy_old_feet_screenchars
  cmp p1gy_screenchar // current p1 screen char for collision point
  bcc filter_collision_unfiltered
filter_collision_filtered:
  pla
  lda #0
  beq filter_collision_done
filter_collision_unfiltered:
  pla    // original collision
filter_collision_done:
  rts

// checks if there is a screen collision at the given pixel coordinate
// inputs:
//   p1gx_coll - x position in pixel coords
//   p1gy_coll - y position in pixel coords
//   p1gx_offset - x offset from position to test
//   p1gy_offset - y offset from position to test
//   collision_mask - mask to match the char material for a collision
// outputs:
//   A - collision_detected - 0 if no collision, not zero otherwise
test_collision:
  lda p1gy_coll+1
  pha
  lda p1gy_coll
  pha
  lda p1gx_coll+1
  pha
  lda p1gx_coll
  pha
  
  // add any potential offset from the point provided
  //lda p1gx_coll // already loaded above
  clc
  adc p1gx_offset
  sta p1gx_coll
  lda p1gx_coll+1
  adc #0
  sta p1gx_coll+1

  lda p1gy_coll
  clc
  adc p1gy_offset
  sta p1gy_coll
  lda p1gy_coll+1
  adc #0
  sta p1gy_coll+1

  // rotate to go from pixels to screen chars
  lsr p1gy_coll+1
  ror p1gy_coll
  lsr p1gy_coll+1
  ror p1gy_coll
  lsr p1gy_coll+1
  ror p1gy_coll

  // store the screen chars for filter test later
  lda p1gy_coll
  sta p1gy_screenchar

  // grab the final bit since it indicates if we're
  // on an odd or even row, thus top or bottom of tile 
  lda p1gy_coll
  ror
  ror collision_tile_coords

  // divide by 2 to get tile row
  lsr p1gy_coll+1
  ror p1gy_coll

  // TODO: treat bottom of level separately. Don't check
  // here since it's called a lot
  ldy p1gy_coll
//   cpy #10
//   bcc tc_not_at_bottom
//   lda #1
//   jmp test_collisiond // collided with bottom of level
// tc_not_at_bottom:
  lda SCR_rowptrs_lo, y
  sta current_tile_row
  lda SCR_rowptrs_hi, y
  sta current_tile_row+1

  // rotate to go from pixels to screen chars
  lsr p1gx_coll+1
  ror p1gx_coll
  lsr p1gx_coll+1
  ror p1gx_coll
  lsr p1gx_coll+1
  ror p1gx_coll

  // grab the final bit since it indicates if we're
  // on and odd or even column, thus left or right of tile 
  lda p1gx_coll
  ror
  ror collision_tile_coords

  // divide by 2 to get tile column
  lsr p1gx_coll+1
  ror p1gx_coll

  ldy p1gx_coll
  lda (current_tile_row), y // get the tile
  tax
  beq test_collisiond      // Tile zero is an empty tile, not collidable
  lda SCR_char_tileset_tag, x
  and collision_mask
  beq test_collisiond
tc_tile_collision:
  // collided with tile, now check the char. the tile might be
  // collidable but the individual char might not be
  // bit 7 has the column, bit 6 has the row
  lda collision_tile_coords
  and #%11000000 // we only use 1st two bits, but others may not be zero
  beq tc_tile_collision_ul
  cmp #%10000000
  beq tc_tile_collision_ur
  cmp #%01000000
  beq tc_tile_collision_ll
  // if here, lower right
  lda SCR_tiles_lr, x
  beq test_collisiond
  tax
  lda SCR_char_attribs, x // get the material
  sta collided_char_attribs
  and collision_mask
  jmp test_collisiond
tc_tile_collision_ul:
  lda SCR_tiles_ul, x
  beq test_collisiond
  tax
  lda SCR_char_attribs, x // get the material
  sta collided_char_attribs
  and collision_mask
  jmp test_collisiond
tc_tile_collision_ur:
  lda SCR_tiles_ur, x
  beq test_collisiond
  tax
  lda SCR_char_attribs, x // get the material
  sta collided_char_attribs
  and collision_mask
  jmp test_collisiond
tc_tile_collision_ll:
  lda SCR_tiles_ll, x
  beq test_collisiond
  tax
  lda SCR_char_attribs, x // get the material
  sta collided_char_attribs
  and collision_mask
  jmp test_collisiond
test_collisiond:
  beq test_collision_no_filter
  // note: A should already have a zero or nonzero for collision detected
  jsr filter_collision
test_collision_no_filter:
  tax
  pla
  sta p1gx_coll
  pla
  sta p1gx_coll+1
  pla
  sta p1gy_coll
  pla
  sta p1gy_coll+1
  txa
  rts


// TODO: one way to make the collision detection faster is
//       to only test a narrower player that doesn't have 3 points
//       to test on the x-axis. Could just do x0=4, x1=10. No x2.

// tests if the player collides with any collidable tiles/characters
// outputs:
//   A - collision_detected, zero if no collision, non-zero if collision
test_player_collisions:

  // get rid of fractional
  lsr p1gx_coll+1
  ror p1gx_coll
  lsr p1gx_coll+1
  ror p1gx_coll
  lsr p1gx_coll+1
  ror p1gx_coll

  lsr p1gy_coll+1
  ror p1gy_coll
  lsr p1gy_coll+1
  ror p1gy_coll
  lsr p1gy_coll+1
  ror p1gy_coll

  // how this routine works: Depending on the collision mask,
  // it will call test_collision using relevant points
  // from the player rectangle
  lda collision_mask
  cmp #(SCR_COLLISION_MASK_RIGHT)
  bne collision_mask_test1
  jmp test_moving_left
collision_mask_test1:
  cmp #(SCR_COLLISION_MASK_RIGHT|SCR_COLLISION_MASK_BOTTOM)
  bne collision_mask_test2
  jmp test_moving_left_up
collision_mask_test2:
  cmp #(SCR_COLLISION_MASK_RIGHT|SCR_COLLISION_MASK_TOP)
  bne collision_mask_test3
  jmp test_moving_left_down
collision_mask_test3:
  cmp #(SCR_COLLISION_MASK_LEFT)
  bne collision_mask_test4
  jmp test_moving_right
collision_mask_test4:
  cmp #(SCR_COLLISION_MASK_LEFT|SCR_COLLISION_MASK_BOTTOM)
  bne collision_mask_test5
  jmp test_moving_right_up
collision_mask_test5:
  cmp #(SCR_COLLISION_MASK_LEFT|SCR_COLLISION_MASK_TOP)
  bne collision_mask_test6
  jmp test_moving_right_down
collision_mask_test6:
  cmp #(SCR_COLLISION_MASK_BOTTOM)
  bne collision_mask_test7
  jmp test_moving_up
collision_mask_test7:
  cmp #(SCR_COLLISION_MASK_TOP)
  bne collision_mask_test8
  jmp test_moving_down
collision_mask_test8:
  // shouldn't happen
  lda #0
  jmp test_player_collisions_done

test_moving_left:
  // test if to left of level
  lda p1gx_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_left_collision

  // test the left edge of the player collision rect
  // x0, y0
  lda #P1_COLLISION_X0
  sta p1gx_offset
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_collision

  // x0, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_collision

  // x0, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_collision

  // x0, y3
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
test_moving_left_collision:
  jmp test_player_collisions_done

test_moving_left_up:
  // test if to left of level
  lda p1gx_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_left_up_collision

  // test if above of level
  lda p1gy_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_left_up_collision

  // test the left and top edges of the player collision rect

  // left edge first
  // x0, y3
  lda #P1_COLLISION_X0
  sta p1gx_offset
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_up_collision

  // x0, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_up_collision

  // x0, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_up_collision

  // x0, y0
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_up_collision

  // now rest of top edge
  // x1, y0
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_left_up_collision

  // x2, y0
  lda #P1_COLLISION_X2
  sta p1gx_offset
  jsr test_collision
test_moving_left_up_collision:
  jmp test_player_collisions_done

test_moving_left_down:
  // test if to left of level
  lda p1gx_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_left_down_collision

  // let's make sure they aren't below the bottom of the level
  lda p1gy_coll
  cmp maxp1gy_px
  bcc test_moving_left_down_not_below
  lda #1
  jmp test_moving_right_down_collision
test_moving_left_down_not_below:

  // test the left and bottom edges of the player collision rect

  // first left edge
  // x0, y0
  lda #P1_COLLISION_X0
  sta p1gx_offset
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_down_collision

  // x0, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_down_collision

  // x0, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_down_collision

  // x0, y3
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
  bne test_moving_left_down_collision

  // now rest of bottom edge
  // x1, y3
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_left_down_collision

  // x2, y3
  lda #P1_COLLISION_X2
  sta p1gx_offset
  jsr test_collision
test_moving_left_down_collision:
  jmp test_player_collisions_done

test_moving_right:
  lda p1gx_coll+1
  cmp maxp1gx_px+1
  bcc test_moving_right_in_bounds
  bne test_moving_right_collision

  lda p1gx_coll
  cmp maxp1gx_px
  bcc test_moving_right_in_bounds
  bne test_moving_right_collision
test_moving_right_in_bounds:
  // test the right edge of the player collision rect
  // x2, y0
  lda #P1_COLLISION_X2
  sta p1gx_offset
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_collision

  // x2, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_collision

  // x2, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_collision

  // x2, y3
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
test_moving_right_collision:
  jmp test_player_collisions_done

test_moving_right_up:
  lda p1gx_coll+1
  cmp maxp1gx_px+1
  bcc test_moving_right_up_in_bounds
  bne test_moving_right_up_collision

  lda p1gx_coll
  cmp maxp1gx_px
  bcc test_moving_right_up_in_bounds
  bne test_moving_right_up_collision
test_moving_right_up_in_bounds:

  // test if above of level
  lda p1gy_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_right_up_collision

  // test the right and top edges of the player collision rect

  // first right edge
  // x2, y3
  lda #P1_COLLISION_X2
  sta p1gx_offset
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_up_collision

  // x2, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_up_collision

  // x2, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_up_collision

  // x2, y0
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_up_collision

  // now rest of top edge
  // x1, y0
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_right_up_collision

  // x0, y0
  lda #P1_COLLISION_X0
  sta p1gx_offset
  jsr test_collision
test_moving_right_up_collision:
  jmp test_player_collisions_done

test_moving_right_down:
  lda p1gx_coll+1
  cmp maxp1gx_px+1
  bcc test_moving_right_down_in_bounds
  bne test_moving_right_down_collision

  lda p1gx_coll
  cmp maxp1gx_px
  bcc test_moving_right_down_in_bounds
  bne test_moving_right_down_collision
test_moving_right_down_in_bounds:
  // let's make sure they aren't below the bottom of the level
  lda p1gy_coll
  cmp maxp1gy_px
  bcc test_moving_right_down_not_below
  lda #1
  bcs test_moving_right_down_collision
test_moving_right_down_not_below:

  // test the right and bottom edges of the player collision rect

  // first right edge
  // x2, y0
  lda #P1_COLLISION_X2
  sta p1gx_offset
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_down_collision

  // x2, y1
  lda #P1_COLLISION_Y1
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_down_collision

  // x2, y2
  lda #P1_COLLISION_Y2
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_down_collision

  // x2, y3
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
  bne test_moving_right_down_collision

  // now rest of bottom edge
  // x1, y3
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_right_down_collision

  // x0, y3
  lda #P1_COLLISION_X0
  sta p1gx_offset
  jsr test_collision
test_moving_right_down_collision:
  jmp test_player_collisions_done

test_moving_up:
  // test if above of level
  lda p1gy_coll+1
  and #%00010000 // would have had a negative position prior to rotating out fractional
  bne test_moving_up_collision

  // test the top edge of the player collision rect
  // x0, y0
  lda #P1_COLLISION_X0
  sta p1gx_offset
  lda #P1_COLLISION_Y0
  sta p1gy_offset
  jsr test_collision
  bne test_moving_up_collision

  // x1, y0
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_up_collision

  // x2, y0
  lda #P1_COLLISION_X2
  sta p1gx_offset
  jsr test_collision
test_moving_up_collision:
  jmp test_player_collisions_done

test_moving_down:
  // let's make sure they aren't below the bottom of the level
  lda p1gy_coll
  cmp maxp1gy_px
  bcc test_moving_down_not_below
  lda #1
  bcs test_moving_right_down_collision
test_moving_down_not_below:

  // test the bottom edge of the player collision rect
  // x0, y3
  lda #P1_COLLISION_X0
  sta p1gx_offset
  lda #P1_COLLISION_Y3
  sta p1gy_offset
  jsr test_collision
  bne test_moving_down_collision

  // x1, y3
  lda #P1_COLLISION_X1
  sta p1gx_offset
  jsr test_collision
  bne test_moving_down_collision

  // x2, y3
  lda #P1_COLLISION_X2
  sta p1gx_offset
  jsr test_collision
test_moving_down_collision:
test_player_collisions_done:
  rts

// How collision detection works.
//   We use a modified version of Bresenham's line drawing algorithm. As we iterate
//   over the major and minor axis, any time we cross over a subpixel to pixel
//   boundary, we check for collisions. If there's a collision, we stop
//   the character movement at that point.
//   
// Note:
//   This is really slow, especially if the player can cross a bunch of subpixels every
//   frame. But it's much more accurate than my previous attempts at collision detection
//   which suffered from small tunnel problems. So we trade speed for accuracy and
//   the game seems fine at 30fps.

.const collision_deltax        = zpb0 // absval of number of subpixels to move in x direction (velocity)
.const collision_deltay        = zpb1 // absval of number of subpixels to move in y direction (velocity)
.const collision_error_counter = zpb2 // used to keep track of errors for Bresenham's line algo
.const collision_flags         = zpb3
.const collision_subpixelsx    = zpb4 // copy of collision_deltax, used as counter
.const collision_subpixelsy    = zpb5 // copy of collision_deltay, used as counter

bresenham_majorx:
  lda #0
  sta collision_error_counter
  sta collision_detected_major
  sta collision_detected_minor
  ldx collision_subpixelsx
  stx zpb8
bresenham_majorx_major_loop:
  lda collision_detected_major
  bne bresenham_majorx_minor_loop // no longer checking collisions in major

  // Step position by a subpixel
  lda p1gx
  clc
  adc p1gx_adder
  sta p1gx_new
  lda p1gx+1
  adc p1gx_adder+1
  sta p1gx_new+1

  // If the first non-subpixel changes, we crossed the boundary
  lda p1gx_new
  eor p1gx
  and #%00001000 // first non subpixel, after fractional
  beq bresenham_majorx_major_no_collisions
bresenham_majorx_major_crossed_pixel:
  lda p1gx_new
  sta p1gx_coll
  lda p1gx_new+1
  sta p1gx_coll+1

  lda p1gy
  sta p1gy_coll
  lda p1gy+1
  sta p1gy_coll+1

  // test for collisions
  jsr test_player_collisions
  // A should be zero if there was a collision after the test, nonzero otherwise
  beq bresenham_majorx_major_no_collisions
  sta collision_detected_major
  lda #0
  sta p1hva
  lda #HV_ZERO
  sta p1hvi
  bne bresenham_majorx_minor_loop // ignore this move, there was a collision
bresenham_majorx_major_no_collisions:
  // update the position
  lda p1gx_new
  sta p1gx
  lda p1gx_new+1
  sta p1gx+1
bresenham_majorx_minor_loop:
  lda collision_detected_minor
  beq bresenham_majorx_minor_loop_continue
  jmp bresenham_majorx_next // no longer checking collisions in minor
bresenham_majorx_minor_loop_continue:
  // add deltay to error count
  lda collision_error_counter
  clc
  adc collision_deltay
  sta collision_error_counter
  cmp collision_deltax
  bcs bresenham_majorx_minor_step
  jmp bresenham_majorx_next
bresenham_majorx_minor_step:
  // if here, step the minor axis
  lda collision_error_counter
  sec
  sbc collision_deltax
  sta collision_error_counter

  lda p1gy
  clc
  adc p1gy_adder
  sta p1gy_coll
  sta p1gy_new
  lda p1gy+1
  adc p1gy_adder+1
  sta p1gy_coll+1
  sta p1gy_new+1

  lda p1gy_new
  eor p1gy
  and #%00001000 // first non subpixel, after fractional
  beq bresenham_majorx_minor_update_position  
bresenham_majorx_minor_crossed_pixel:
  // get the latest x-value
  lda p1gx
  sta p1gx_coll
  lda p1gx+1
  sta p1gx_coll+1

  // test for collisions
  jsr test_player_collisions
  // A should be zero if there was a collision after the test, nonzero otherwise
  beq bresenham_majorx_minor_update_position // no collisions
  sta collision_detected_minor

  lda collision_mask
  and #SCR_COLLISION_MASK_BOTTOM
  bne bresenham_majorx_minor_hit_head
  jmp bresenham_majorx_next
bresenham_majorx_minor_hit_head:
  // hit head on bottom of something, stop movement
  play_sound(1)

  lda #VV_ZERO
  sta p1vvi
  lda #0
  sta p1vva
  jmp bresenham_majorx_next
bresenham_majorx_minor_update_position:
  // update the position
  lda p1gy_new
  sta p1gy
  lda p1gy_new+1
  sta p1gy+1
bresenham_majorx_next:
  dec zpb8
  ldx zpb8
  beq bresenham_majorx_done
  jmp bresenham_majorx_major_loop
bresenham_majorx_done:
  rts

bresenham_majory:
  lda #0
  sta collision_error_counter
  sta collision_detected_major
  sta collision_detected_minor
  ldx collision_subpixelsy
  stx zpb8
bresenham_majory_major_loop:
  lda collision_detected_major
  bne bresenham_majory_minor_loop // no longer checking collisions in major

  // Step position by a subpixel
  lda p1gy
  clc
  adc p1gy_adder
  sta p1gy_new
  lda p1gy+1
  adc p1gy_adder+1
  sta p1gy_new+1

  // If the first non-subpixel changes, we crossed the boundary
  lda p1gy_new
  eor p1gy
  and #%00001000 // first non subpixel, after fractional
  beq bresenham_majory_major_update_position
bresenham_majory_major_crossed_pixel:
  lda p1gy_new
  sta p1gy_coll
  lda p1gy_new+1
  sta p1gy_coll+1

  lda p1gx
  sta p1gx_coll
  lda p1gx+1
  sta p1gx_coll+1

  // test for collisions
  jsr test_player_collisions
  // A should be zero if there was a collision after the test, nonzero otherwise
  beq bresenham_majory_major_update_position
  sta collision_detected_major

  lda collision_mask
  and #SCR_COLLISION_MASK_BOTTOM
  bne bresenham_majory_hit_head
  jmp bresenham_majory_minor_loop
bresenham_majory_hit_head:
  // hit head on bottom of something, stop movement
  play_sound(1)

  lda #VV_ZERO
  sta p1vvi
  lda #0
  sta p1vva
  jmp bresenham_majory_minor_loop
bresenham_majory_major_update_position:
  // update the position
  lda p1gy_new
  sta p1gy
  lda p1gy_new+1
  sta p1gy+1
bresenham_majory_minor_loop:
  lda collision_detected_minor
  beq bresenham_majory_minor_loop_continue
  jmp bresenham_majory_next // no longer checking collisions in minor
bresenham_majory_minor_loop_continue:
  // add deltax to error count
  lda collision_error_counter
  clc
  adc collision_deltax
  sta collision_error_counter
  cmp collision_deltay
  bcs bresenham_majory_minor_step
  jmp bresenham_majory_next
bresenham_majory_minor_step:
  // if here, step the minor axis
  lda collision_error_counter
  sec
  sbc collision_deltay
  sta collision_error_counter

  lda p1gx
  clc
  adc p1gx_adder
  sta p1gx_coll
  sta p1gx_new
  lda p1gx+1
  adc p1gx_adder+1
  sta p1gx_coll+1
  sta p1gx_new+1

  lda p1gx_new
  eor p1gx
  and #%00001000 // first non subpixel, after fractional
  beq bresenham_majory_minor_no_collisions  
bresenham_majory_minor_crossed_pixel:
  // get the latest y-value
  lda p1gy
  sta p1gy_coll
  lda p1gy+1
  sta p1gy_coll+1

  // test for collisions
  jsr test_player_collisions
  // A should be zero if there was a collision after the test, nonzero otherwise
  beq bresenham_majory_minor_no_collisions // no collisions
  sta collision_detected_minor
  lda #0
  sta p1hva
  lda #HV_ZERO
  sta p1hvi
  bne bresenham_majory_next // ignore this move, there was a collision
bresenham_majory_minor_no_collisions:
  // update the position
  lda p1gx_new
  sta p1gx
  lda p1gx_new+1
  sta p1gx+1
bresenham_majory_next:
  dec zpb8
  ldx zpb8
  beq bresenham_majory_done
  jmp bresenham_majory_major_loop
bresenham_majory_done:
  rts

updp1p:
  lda #0
  sta collision_mask

  // first, let's figure out direction we're moving and do some setup
  lda p1hva
  bmi updp1p_hl
  beq updp1p_hz
  // moving right
  lda collision_mask
  ora #SCR_COLLISION_MASK_LEFT
  sta collision_mask
  lda p1hvi
  sec
  sbc #HV_ZERO
  sta collision_deltax
  sta collision_subpixelsx
  lda #1
  sta p1gx_adder
  lda #0
  sta p1gx_adder+1
  beq updp1p_vadder
updp1p_hl:
  // moving left
  lda collision_mask
  ora #SCR_COLLISION_MASK_RIGHT
  sta collision_mask
  lda #HV_ZERO
  sec
  sbc p1hvi
  sta collision_deltax
  sta collision_subpixelsx
  lda #$ff // will effectively end up being a subtraction
  sta p1gx_adder
  sta p1gx_adder+1
  bne updp1p_vadder
updp1p_hz:
  // not moving horizontally
  lda #0
  sta p1gx_adder
  sta p1gx_adder+1
  sta collision_deltax
  sta collision_subpixelsx
updp1p_vadder:
  lda p1vva
  bmi updp1p_vu
  beq updp1p_vz
  // moving down
  lda collision_mask
  ora #SCR_COLLISION_MASK_TOP
  sta collision_mask
  lda p1vvi
  sec
  sbc #VV_ZERO
  sta collision_deltay
  sta collision_subpixelsy
  lda #1
  sta p1gy_adder
  lda #0
  sta p1gy_adder+1
  beq updp1p_setup_done
updp1p_vu:
  // moving up
  lda collision_mask
  ora #SCR_COLLISION_MASK_BOTTOM
  sta collision_mask
  lda #VV_ZERO
  sec
  sbc p1vvi
  sta collision_deltay
  sta collision_subpixelsy
  lda #$ff // will effectively be a subtraction
  sta p1gy_adder
  sta p1gy_adder+1
  bne updp1p_setup_done
updp1p_vz:
  // not moving vertically
  lda #0
  sta collision_subpixelsy
  sta p1gy_adder
  sta p1gy_adder+1
  sta collision_deltay
updp1p_setup_done:
  lda collision_subpixelsx
  bne updp1p_moving
  lda collision_subpixelsy
  bne updp1p_moving

  jmp updp1p_positiond // player didn't move

updp1p_moving:
  lda collision_subpixelsx
  cmp collision_subpixelsy
  bcs updp1p_majoraxisx
  jsr bresenham_majory
  jmp updp1p_positiond
updp1p_majoraxisx:
  jsr bresenham_majorx
updp1p_positiond:
  rts

updp1p_sprite:
  // now let's update the player sprite

  // we're going to set p1lx, p1ly to the location relative
  // to the left side of the screen, in pixel coords
  lda p1gx
  sta p1lx
  lda p1gx+1
  sta p1lx+1
  lda p1gy
  sta p1ly
  lda p1gy+1
  sta p1ly+1

  // get rid of fractional
  lsr p1lx+1
  ror p1lx
  lsr p1lx+1
  ror p1lx
  lsr p1lx+1
  ror p1lx

  lsr p1ly+1
  ror p1ly
  lsr p1ly+1
  ror p1ly
  lsr p1ly+1
  ror p1ly

  // p1lx/p1ly are now in pixel coords, global position

  // subtract the first column visible from the global position to get the local 
  // position relative to left side of screen, in pixel coordinates
  lda p1lx
  sec
  sbc SCR_first_visible_column_pixels
  sta p1sx
  lda p1lx+1
  sbc SCR_first_visible_column_pixels+1
  sta p1sx+1

  // now add border areas to get sprite position
  lda p1sx
  clc
  adc #31
  sta p1sx
  lda p1sx+1
  adc #0
  sta p1sx+1

  // and now adjust for how much we're scrolled
  lda p1sx
  sec
  sbc SCR_scroll_offset
  sta p1sx
  lda p1sx+1
  sbc #0
  sta p1sx+1

  // now add border area for y
  lda p1ly
  clc
  adc #50
  sta p1sy
  lda p1ly+1
  adc #0
  sta p1sy+1

  // sprite position is now calculated and stored in p1sx/p1sy, but we might
  // need to scroll which will impact the sprite position
  lda p1sx+1
  bne updp1psprite // no need to scroll if past scroll point
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
  lda p1sx+1
  sbc #0
  sta p1sx+1
  jmp updp1psprite
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
  lda p1sx+1
  adc #0
  sta p1sx+1
updp1psprite:
  lda p1sy
  sta SPRITE_YPOS_BASE+0
  lda p1sx
  sta SPRITE_XPOS_BASE+0
  lda p1sx+1
  bne updp1pmsb
  lda SPRITE_MSB
  and #%11111110
  sta SPRITE_MSB
  jmp updp1pd
updp1pmsb:
  lda SPRITE_MSB
  ora #%00000001
  sta SPRITE_MSB
updp1pd:
  lda p1gx
  sta p1gx_pixels
  lda p1gx+1
  sta p1gx_pixels+1
  lsr p1gx_pixels+1
  ror p1gx_pixels
  lsr p1gx_pixels+1
  ror p1gx_pixels
  lsr p1gx_pixels+1
  ror p1gx_pixels
  rts


// tests two enemy distances from the player, left enemy and right enemy.
// inputs:
//   zpb0, zpb1 - the left enemy pos to test against
//   zpb2, zpb3 - the right enemy pos to test against
// outputs:
//   A - 0 if left enemy is closer to player, 1 if right enemy is closer, 0 if equal
upd_enemies_buffer_test_dist:
  lda p1gx_pixels
  sec
  sbc zpb0
  sta zpb4
  lda p1gx_pixels+1
  sbc zpb1
  sta zpb5

  bpl player_not_left_of_left
  // if here, the player is to the left of the left-hand enemy,
  // therefore the player must be closer the left-hand enemy
  lda #0
  beq upd_enemies_buffer_test_distd
player_not_left_of_left:
  lda zpb2
  sec
  sbc p1gx_pixels
  sta zpb6
  lda zpb3
  sbc p1gx_pixels+1
  sta zpb7

  bpl upd_enemies_player_in_middle
  // if here, the player is to right of the right-hand enemy,
  // therefore the player must be closer to the right-hand enemy 
  lda #1
  bne upd_enemies_buffer_test_distd
upd_enemies_player_in_middle:
  // if here, the player is in between enemies_min and enemies_max
  // so we compare distances from players to each of the ends.
  lda zpb5
  cmp zpb7
  bcc upd_enemies_buffer_test_dist_right_further
  beq upd_enemies_buffer_test_lo
  bcs upd_enemies_buffer_test_dist_left_further
upd_enemies_buffer_test_lo:
  lda zpb4
  cmp zpb6
  bcc upd_enemies_buffer_test_dist_right_further
upd_enemies_buffer_test_dist_left_further:
  // if here, the player is closer to the right side
  // or they are equal
  lda #1
  bne upd_enemies_buffer_test_distd
upd_enemies_buffer_test_dist_right_further:
  // if here, the player is closer to the left side
  lda #0
upd_enemies_buffer_test_distd:
  rts

// This updates the buffer of enemies we care about in terms of seeing if
//   they might be on screen, updating their positions, etc.
// Care must be taken in how the enemies are placed on the screen such
//   that we don't have the possibility of more enemies possibly
//   on the screen than can fit in the buffer.
// NOTE: only the enemies' min range value is used for this due to simplicity.
upd_enemies_buffer:
  // first see how far away the enemy *before* buffer_min is
  // to the player compared to how far away the enemy at the current max
  // is. If we're closer, move the buffer lower
  ldx enemies_buffer_min
  beq upd_enemies_buffer_test_upper // already at min
  dex
  lda enemies_rangex_min_lo, x
  sta zpb0
  lda enemies_rangex_min_hi, x
  sta zpb1
  ldx enemies_buffer_max
  dex // max is one beyond the end of our array
  lda enemies_rangex_min_lo, x
  sta zpb2
  lda enemies_rangex_min_hi, x
  sta zpb3
  jsr upd_enemies_buffer_test_dist
  // A should now contain the output of the test
  bne upd_enemies_buffer_test_upper // player closer to max
  // if here, let's move the buffer lower.
  dec enemies_buffer_min
  dec enemies_buffer_max
  jmp upd_enemies_bufferd
upd_enemies_buffer_test_upper:
  // now check to see if we're closer to the current max of the buffer.
  // Check the enemy *after* the current max and compare it to our
  // min. If we're closer to the *after*, move the buffer up.
  ldx enemies_buffer_max
  cpx enemies_count
  beq upd_enemies_bufferd        // end of buffer already at end of enemies
  //dex                          // get enemy one past end of current buffer
                                 // which is actually max since max is 1+ actual buffer
  lda enemies_rangex_min_lo, x
  sta zpb2
  lda enemies_rangex_min_hi, x
  sta zpb3
  ldx enemies_buffer_min         // existing min
  lda enemies_rangex_min_lo, x
  sta zpb0
  lda enemies_rangex_min_hi, x
  sta zpb1
  jsr upd_enemies_buffer_test_dist
  beq upd_enemies_bufferd        // player closer to min, don't move max
  // move the buffer higher
  inc enemies_buffer_max
  inc enemies_buffer_min
upd_enemies_bufferd:
  rts


// update enemy positions
upd_enemies_pos:
  ldx enemies_buffer_min
upd_enemies_pos_enemy:
  lda enemies_flags, X
  and #ENEMY_FLAG_DEAD
  beq upd_enemies_test_dying
  jmp upd_enemies_pos_next_enemy
upd_enemies_test_dying:
  lda enemies_flags, X
  and #ENEMY_FLAG_DYING
  beq upd_enemies_pos_alive
  jmp upd_enemies_pos_next_enemy
upd_enemies_pos_alive:
  ldy enemies_type, x
  lda enemies_hspeed, y
  beq upd_enemies_pos_vertical
upd_enemies_pos_horizontal:
  lda enemies_flags, x
  and #ENEMY_FLAG_HDIRECTION
  beq enemy_moving_left
  // if here, enemy moving right
  lda enemies_posx_lo, x
  clc
  adc enemies_hspeed, y
  sta enemies_posx_lo, x
  lda enemies_posx_hi, x
  adc #0
  sta enemies_posx_hi, x
  cmp enemies_rangex_max_hi, x
  bcc upd_enemies_pos_vertical  // not ready to turn back left
  bne enemy_start_moving_left
  lda enemies_posx_lo, x
  cmp enemies_rangex_max_lo, x
  bcc upd_enemies_pos_vertical  // not ready to turn back left
enemy_start_moving_left:
  lda enemies_rangex_max_lo, x
  sta enemies_posx_lo, x
  lda enemies_rangex_max_hi, x
  sta enemies_posx_hi, x
  
  lda #ENEMY_FLAG_HDIRECTION
  eor #%11111111
  and enemies_flags, x
  sta enemies_flags, x
  jmp upd_enemies_pos_vertical
enemy_moving_left:
  lda enemies_posx_lo, x
  sec
  sbc enemies_hspeed, y
  sta enemies_posx_lo, x
  lda enemies_posx_hi, x
  sbc #0
  sta enemies_posx_hi, x
  cmp enemies_rangex_min_hi, x
  bcc enemy_start_moving_right    // ready to turn back right
  bne upd_enemies_pos_vertical
  lda enemies_posx_lo, x
  cmp enemies_rangex_min_lo, x
  bcc enemy_start_moving_right    // ready to turn back right
  bcs upd_enemies_pos_vertical  // keep moving left
enemy_start_moving_right:
  lda enemies_rangex_min_lo, x
  sta enemies_posx_lo, x
  lda enemies_rangex_min_hi, x
  sta enemies_posx_hi, x
  lda enemies_flags, x
  ora #ENEMY_FLAG_HDIRECTION       // now moving right
  sta enemies_flags, x

upd_enemies_pos_vertical:
  lda enemies_vspeed, y
  beq upd_enemies_pos_next_enemy

  lda enemies_flags, x
  and #ENEMY_FLAG_VDIRECTION
  beq enemy_moving_up
  // if here, enemy moving down
  lda enemies_posy, x
  clc
  adc enemies_vspeed, y
  sta enemies_posy, x
  cmp enemies_rangey_max, x
  bcc upd_enemies_pos_next_enemy  // not ready to start back up
enemy_start_moving_up:
  lda enemies_rangey_max, x
  sta enemies_posy, x
  
  lda #ENEMY_FLAG_VDIRECTION
  eor #%11111111
  and enemies_flags, x
  sta enemies_flags, x
  jmp upd_enemies_pos_next_enemy
enemy_moving_up:
  lda enemies_posy, x
  sec
  sbc enemies_vspeed, y
  sta enemies_posy, x
  cmp enemies_rangey_min, x
  bcc enemy_start_moving_down    // ready to start going down
  bne upd_enemies_pos_next_enemy
enemy_start_moving_down:
  lda enemies_rangey_min, x
  sta enemies_posy, x
  lda enemies_flags, x
  ora #ENEMY_FLAG_VDIRECTION       // now moving down
  sta enemies_flags, x
upd_enemies_pos_next_enemy:
  inx
  cpx enemies_buffer_max
  beq upd_enemies_posd
  jmp upd_enemies_pos_enemy
upd_enemies_posd:
  rts

upd_enemies_sprites:
  ldx enemies_buffer_min
upd_enemies_sprites_enemy:
  // check if the enemy is dead
  lda enemies_flags, x
  and #ENEMY_FLAG_DEAD
  beq test_dying
  jmp upd_enemies_sprites_next_enemy // dead
test_dying:
  lda enemies_flags, x
  and #ENEMY_FLAG_DYING
  beq upd_enemies_sprites_pos // not dying
  ldy enemies_dead_animation_frames, x
  cpy #ENEMY_ANIMATION_FRAMES_DEATH
  bne already_dying
  // just started dying, swap out the sprite
  ldy enemies_type, x
  lda enemies_animations_death, y
  clc
  adc #SPRITE_PTR_FIRST_B2
  ldy enemies_sprite_base_offset, x
  sta SPRITE_PTR_BASE_FB, y
  sta SPRITE_PTR_BASE_BB, y
  dec enemies_dead_animation_frames, x
  jmp upd_enemies_sprites_pos
already_dying:
  dey
  beq enemy_died
  tya
  sta enemies_dead_animation_frames, x
  jmp upd_enemies_sprites_pos
enemy_died:
  lda #ENEMY_FLAG_DYING
  eor #%11111111
  and enemies_flags, x // set dying to false
  ora #ENEMY_FLAG_DEAD // set dead to true
  sta enemies_flags, x
  jmp enemy_disable_sprite
upd_enemies_sprites_pos:
  lda enemies_posx_lo, x
  sec
  sbc SCR_first_visible_column_pixels
  sta zpb0
  lda enemies_posx_hi, x
  sbc SCR_first_visible_column_pixels+1
  sta zpb1
  bpl enemy_not_offscreen_left
  
  // if here, it's possible the enemy may be off the screen to the left, but we haven't
  // yet taken into account the width of the enemy character yet.
  // Add back the width of the character. If the high byte is still negative,
  // that means the enemy really is off the screen to the left.
  lda zpb0
  clc
  adc enemies_width, x
  lda zpb1
  adc #0
  bpl enemy_onscreen
  jmp enemy_offscreen
enemy_not_offscreen_left:
  // if here, the enemy is further to the right in the level than
  // the first visible column. Now check if it's offscreen
  // to the right
  lda zpb1
  bne test_onscreen_way_off
  jmp enemy_onscreen  // < 256 pixels, so onscreen
test_onscreen_way_off:
  cmp #2
  bcc test_onscreen_msb
  jmp enemy_offscreen // >= 512, so definitely not on screen
test_onscreen_msb:
  // if here, enemy is further right than 256 pixels,
  // but less than 512, so test the low byte and compare
  // to the low byte of the screen width
  lda zpb0
  cmp #<(scrwidth*8)
  bcc enemy_onscreen
  jmp enemy_offscreen // off screen to the right
enemy_onscreen:
  // if here, enemy on screen, so we will want to draw it
  // now let's add the border offset
  lda zpb0
  clc
  adc #31
  sta zpb0
  lda zpb1
  adc #0
  sta zpb1

  // now let's consider the scrolling
  lda zpb0
  sec
  sbc SCR_scroll_offset
  sta zpb0
  lda zpb1
  sbc #0
  sta zpb1
  beq enemy_nomsb

  // set sprite msb
  lda SPRITE_MSB
  ora enemies_sprite_slots, x
  sta SPRITE_MSB
  jmp enemy_lsb
enemy_nomsb:
  // disable msb for this sprite
  lda enemies_sprite_slots, x
  eor #%11111111 // invert
  and SPRITE_MSB
  sta SPRITE_MSB
enemy_lsb:
  ldy enemies_sprite_pos_offset, x
  lda zpb0
  sta SPRITE_XPOS_BASE, y
enemy_y:
  lda enemies_posy, x
  clc
  adc #50
  sta SPRITE_YPOS_BASE, y
enemy_enable_sprite:
  lda SPRITE_ENABLE
  and enemies_sprite_slots, x
  beq sprite_not_already_enabled
debug1:
  jmp upd_enemies_sprites_next_enemy
sprite_not_already_enabled:
  lda enemies_flags, x
  ora #ENEMY_FLAG_ONSCREEN
  sta enemies_flags, x

  ldy enemies_type, x
  lda enemies_animations_positive, y  // get the first animation frame
  tay
  lda spritesbatch2_spriteset_attrib_data, y // get the color data
  pha
  and #%10000000
  beq enemy_enable_sprite_single_color

  // set multicolor flag
  lda enemies_sprite_slots, x
  ora SPRITE_MC_MODE
  sta SPRITE_MC_MODE
  bne enemy_enable_sprite_color
enemy_enable_sprite_single_color:
  lda enemies_sprite_slots, x
  eor #%11111111
  and SPRITE_MC_MODE
  sta SPRITE_MC_MODE
enemy_enable_sprite_color:
  pla
  and #%00001111 // get just color part

  ldy enemies_sprite_base_offset, x
  sta SPRITE_COLOR_BASE, y

  lda enemies_sprite_slots, x
  ora SPRITE_ENABLE
  sta SPRITE_ENABLE
  jmp upd_enemies_sprites_next_enemy
enemy_offscreen:
  lda #ENEMY_FLAG_ONSCREEN
  eor #%11111111
  and enemies_flags, x
  sta enemies_flags, x
enemy_disable_sprite:
  // disable the sprite
  lda enemies_sprite_slots, x
  eor #%11111111 // invert
  and SPRITE_ENABLE
  sta SPRITE_ENABLE
  jmp upd_enemies_sprites_next_enemy
upd_enemies_sprites_next_enemy:
  inx
  cpx enemies_buffer_max
  beq upd_enemies_spritesd
  jmp upd_enemies_sprites_enemy
upd_enemies_spritesd:
  rts

.const current_enemy_xpos_lo = zpb5
.const current_enemy_xpos_hi = zpb6
.const current_enemy_ypos_lo = zpb7
// TODO: for finding the enemy, check if it's dead.
enemy_collisions_kill:
  ldx enemies_buffer_min
enemies_collisions_kill_loop:
  lda enemies_flags, x
  and #ENEMY_FLAG_DEAD
  bne enemy_collision_skip

  lda enemies_flags, x
  and #ENEMY_FLAG_DYING
  bne enemy_collision_skip

  lda enemies_flags, x
  and #ENEMY_FLAG_ONSCREEN
  bne enemy_test_collision

enemy_collision_skip:
  jmp enemies_collisions_kill_loop_next
enemy_test_collision:
  // this enemy is onscreen, let's test for a collision
  // get the enemy sprite info
  ldy enemies_sprite_pos_offset, x
  lda SPRITE_XPOS_BASE, y
  sta current_enemy_xpos_lo
  lda SPRITE_YPOS_BASE, y
  sta current_enemy_ypos_lo

  lda SPRITE_MSB
  and enemies_sprite_slots, x
  bne enemy_msb_set
  lda #0
  sta current_enemy_xpos_hi
  beq enemy_loaded
enemy_msb_set:
  lda #1
  sta current_enemy_xpos_hi
enemy_loaded:
  ldy enemies_type, x

  // test to see if the player's collision rect collides with enemy's
test_left_of_enemy:
  // first compare right side of player with left of enemy
  lda p1sx+1
  sta zpb1
  lda p1sx
  sta zpb0
  clc
  adc #P1_COLLISION_OFFSETX
  adc #P1_COLLISION_WIDTH
  sta zpb0
  lda zpb1
  adc #0
  sta zpb1

  lda current_enemy_xpos_lo
  clc
  adc enemies_collision_offsetx, y
  sta zpb2
  lda current_enemy_xpos_hi
  adc #0
  sta zpb3

  lda zpb1
  cmp zpb3
  bcc player_left_of_enemy
  lda zpb0
  cmp zpb2
  bcc player_left_of_enemy
  bcs test_right_of_enemy
player_left_of_enemy:
  jmp enemies_collisions_kill_loop_next

test_right_of_enemy:
  // now compare left side of player to right side of enemy
  lda zpb0
  sec
  sbc #P1_COLLISION_WIDTH
  sta zpb0
  lda zpb1
  sbc #0
  sta zpb1

  lda zpb2
  clc
  adc enemies_collision_width, y
  sta zpb2
  lda zpb3
  adc #0
  sta zpb3

  lda zpb3
  cmp zpb1
  bcc player_right_of_enemy
  lda zpb2
  cmp zpb0
  bcc player_right_of_enemy
  bcs test_above_enemy
player_right_of_enemy:
  jmp enemies_collisions_kill_loop_next
test_above_enemy:

  // now compare the bottom of the player's collision rect to the top of the enemy
  lda p1sy
  sta zpb0
  clc
  adc #P1_COLLISION_OFFSETY
  adc #P1_COLLISION_HEIGHT
  sta zpb0    

  lda current_enemy_ypos_lo
  clc
  adc enemies_collision_offsety, y
  sta zpb2

  lda zpb0
  cmp zpb2
  bcc player_above_enemy
  bcs test_below_enemy
player_above_enemy:
  jmp enemies_collisions_kill_loop_next

test_below_enemy:
  // now compare the top of the player's collision rect to the bottom of the enemy
  lda zpb0
  sec
  sbc #P1_COLLISION_HEIGHT
  sta zpb0

  lda zpb2
  clc
  adc enemies_collision_height, y
  sta zpb2

  lda zpb2
  cmp zpb0
  bcc player_below_enemy
  bcs test_stomp_enemy
player_below_enemy:
  jmp enemies_collisions_kill_loop_next

test_stomp_enemy:
  // if here, there's a collision with this enemy
  inc enemy_collided_temp

  // check if we landed on the top of the enemy
  lda p1sy_old
  clc
  adc #P1_COLLISION_OFFSETY
  adc #P1_COLLISION_HEIGHT
  sta zpb0

  lda current_enemy_ypos_lo
  clc
  adc enemies_collision_offsety, y
  sta zpb2
  cmp zpb0
  bcc player_killed // player was below enemy on last frame, didn't stomp  

  lda p1sy
  clc
  adc #P1_COLLISION_OFFSETY
  adc #P1_COLLISION_HEIGHT
  sta zpb0

  cmp zpb2
  bcs enemy_killed // after new move, player at or below top of enemy
player_killed:
  jsr player_died
  jmp enemy_collisions_kill_done
enemy_killed:
  inc enemy_kills

  play_sound(2)
  // Set the enemy to dying.
  lda enemies_flags, x
  ora #ENEMY_FLAG_DYING
  sta enemies_flags, x

  // Make the player bounce upwards
  lda #VV_BOUNCE
  sta p1vvi
  // lda #VV_ZERO
  // sec
  // sbc p1vvi
  // sta p1vva

enemies_collisions_kill_loop_next:
  inx
  cpx enemies_buffer_max
  beq enemy_collisions_kill_done
  jmp enemies_collisions_kill_loop
enemy_collisions_kill_done:
  rts

updanim_p1:
  lda spritesbatch1_spriteset_attrib_data+0
  sta SPRITE_COLOR_BASE+0
  // sprite offsets:
  // offset 0 - standing
  // offset 1 - moving, first frame
  // offset 2 - moving, second frame
  // offset 3 - moving, third frame
  // offset 4 - turning
  // offset 5 - jumping
  lda player_animation_flag
  and #%11000000
  cmp #%10000000
  beq updanim_p1_jumping_left

  lda player_animation_flag
  and #%11000000
  cmp #%11000000
  beq updanim_p1_jumping_right

  lda player_animation_flag
  and #%11100000
  cmp #%00100000
  beq updanim_p1_moving_left

  lda player_animation_flag
  and #%11100000
  cmp #%01100000
  beq updanim_p1_moving_right

  lda player_animation_flag
  and #%01100000
  cmp #%00000000
  beq updanim_p1_standing_left

  lda player_animation_flag
  and #%01100000
  cmp #%01000000
  beq updanim_p1_standing_right

updanim_p1_jumping_left:
  lda #(P1_FACING_LEFT_OFFSET+5)
  bne updanim_p1_offset_selected
updanim_p1_jumping_right:
  lda #(P1_FACING_RIGHT_OFFSET+5)
  bne updanim_p1_offset_selected
updanim_p1_moving_left:
  lda #(P1_FACING_LEFT_OFFSET+1)
  clc
  adc animation_index
  bne updanim_p1_offset_selected
updanim_p1_moving_right:
  lda #(P1_FACING_RIGHT_OFFSET+1)
  clc
  adc animation_index
  bne updanim_p1_offset_selected
updanim_p1_standing_left:
  lda #(P1_FACING_LEFT_OFFSET+0)
  bne updanim_p1_offset_selected
updanim_p1_standing_right:
  lda #(P1_FACING_RIGHT_OFFSET+0)
updanim_p1_offset_selected:
  sta SPRITE_PTR_BASE_FB
  sta SPRITE_PTR_BASE_BB
updanim_p1_done:
  rts

updanim_enemy:
  ldx enemies_buffer_min
updanim_enemy_loop:
  lda enemies_flags, x
  and #ENEMY_FLAG_DEAD
  bne updanim_enemy_next_enemy

  lda enemies_flags, x
  and #ENEMY_FLAG_DYING
  bne updanim_enemy_next_enemy

  ldy enemies_type, x

  // default to the vertical animations as long as the enemy
  // moves up and down
  lda enemies_vspeed, y
  beq use_horizontal_animations
  lda enemies_flags, x
  and #ENEMY_FLAG_VDIRECTION
  cmp #ENEMY_FLAG_VDIRECTION
  beq updanim_enemy_moving_positive
  bne updanim_enemy_moving_negative
use_horizontal_animations:
  lda enemies_flags, x
  and #ENEMY_FLAG_HDIRECTION
  cmp #ENEMY_FLAG_HDIRECTION
  beq updanim_enemy_moving_positive
  bne updanim_enemy_moving_negative
updanim_enemy_moving_negative:
  // if here, enemy is moving in the negative direction (left or up)
  lda enemies_animations_negative, y // get index 0 of animation
  clc
  adc animation_index
  jmp updanim_enemy_sprite_selected
updanim_enemy_moving_positive:
  lda enemies_animations_positive, y // get index 0 of animation
  clc
  adc animation_index
updanim_enemy_sprite_selected:
  // TODO: is this right?
  adc #SPRITE_PTR_FIRST_B2
  ldy enemies_sprite_base_offset, x
  sta SPRITE_PTR_BASE_FB, y
  sta SPRITE_PTR_BASE_BB, y
updanim_enemy_next_enemy:
  inx
  cpx enemies_buffer_max
  bcs updanim_enemiesd
  jmp updanim_enemy_loop
updanim_enemiesd:
  rts

updanim:
  lda animation_frame
  beq updanim_index
  cmp #30
  beq updanim_index
  cmp #20
  beq updanim_index
  cmp #10
  beq updanim_index
  jmp updanim_index_done // no need to update sprite indices
updanim_index:
  inc animation_index
  lda animation_index
  cmp #3
  bne updanim_index_done
  // animation wrapped
  lda #0
  sta animation_index
updanim_index_done:
  jsr updanim_p1
  jsr updanim_enemy

  dec animation_frame
  bpl updanim_done
  // wrapped
  lda #30
  sta animation_frame
updanim_done:
  rts

clear_sound_effect:
  // lda #0
  // sta VOICE3_LF
  // sta VOICE3_HF
  // sta VOICE3_CONTROL
  // sta VOICE3_ENV_AD
  // sta VOICE3_ENV_SR

  // done playing this sound effect
  lda VOICE3_CONTROL
  and #%11111110 // gate off
  sta VOICE3_CONTROL

  rts

.macro play_sound(sound_index) {
  lda #sound_index
  sta sound_effect_index
  lda #1
  sta sound_effect_ready
}

upd_sound_effects:
  lda sound_effect_ready
  bne sound_effect_new

  ldx current_sound_effect_ticks_left
  bne sound_effect_next_tick
  jmp upd_sound_effectsd

sound_effect_new:
  jsr clear_sound_effect


  ldx sound_effect_index

  lda sound_effects_pulse_lo, x
  sta VOICE3_PULSE_LO
  lda sound_effects_pulse_hi, x
  sta VOICE3_PULSE_HI

  lda sound_effects_attack_decay, x
  sta VOICE3_ENV_AD
  lda sound_effects_sustain_release, x
  sta VOICE3_ENV_SR

  lda sound_effects_freq_lo, x
  sta current_sound_effect_freq_lo
  sta VOICE3_LF
  lda sound_effects_freq_hi, x
  sta current_sound_effect_freq_hi
  sta VOICE3_HF

  // Reset the oscillator so we always start from the same pitch
  lda VOICE3_CONTROL
  ora #%00001000  // set test bit
  sta VOICE3_CONTROL
  and #%00000000  // clear test bit
  sta VOICE3_CONTROL
  ora sound_effects_waveform, x
  sta VOICE3_CONTROL

  lda sound_effects_num_ticks, x
  sta current_sound_effect_ticks_left

  lda sound_effects_sweep_num_ticks, x
  sta current_sound_effect_sweep_ticks_left

  lda sound_effects_sweep_adder_lo, x
  sta current_sound_effect_sweep_adder_lo

  lda sound_effects_sweep_adder_hi, x
  sta current_sound_effect_sweep_adder_hi

  lda #0
  sta sound_effect_ready

  jmp upd_sound_effectsd  // no sweep on first tick
sound_effect_next_tick:
  dex
  stx current_sound_effect_ticks_left
  beq sound_effect_done
sound_effect_sweep:
  ldx current_sound_effect_sweep_ticks_left
  beq sound_effect_sweep_done
  dex
  stx current_sound_effect_sweep_ticks_left
  // still sweeping
  lda current_sound_effect_freq_lo
  clc
  adc current_sound_effect_sweep_adder_lo
  sta VOICE3_LF
  lda current_sound_effect_freq_hi
  adc current_sound_effect_sweep_adder_hi
  sta VOICE3_HF
  jmp sound_effect_sweep_done
sound_effect_done:
  lda #0
  sta current_sound_effect_ticks_left
  sta current_sound_effect_sweep_ticks_left
  jsr clear_sound_effect
sound_effect_sweep_done:
upd_sound_effectsd:
  rts

// read the joystick
injs:
  lda $dc00
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

inkbd:
  lda #%11111110  // Write column zero of the matrix
  sta CIA_PORTA

  lda CIA_PORTB
  and #%00010000  // Read row 4 (F1 key at column zero)
  bne inkbd_done
  // if here, f1 pressed
  jsr restart_level

inkbd_done:
  rts

// gettime:
//   jsr $ffde
//   sty time+2
//   stx time+1
//   sta time
//   rts

// TODO: make sure to initialize all variables

minx:        .byte 0,0
maxx:        .byte 0,0
miny:        .byte 0,0
maxy:        .byte 0,0


p1hvi:       .byte 0
p1hva:       .byte 0,0
p1gx_pixels: .byte 0,0
p1lx:        .byte 0,0
p1lx_delta:  .byte 0,0
p1lx2:       .byte 0,0
p1cx:        .byte 0,0
p1cx2:       .byte 0
p1vvi:       .byte 0
p1vva:       .byte 0,0
p1ly:        .byte 0,0 // 2 bytes due to a quirk in calculation
p1ly_delta:  .byte 0,0
p1ly_prev:   .byte 0,0
p1ly2:       .byte 0,0
p1cy:        .byte 0,0
p1cy2:       .byte 0,0
p1hvt:       .byte 0
p1vvt:       .byte 0

// event buffers for each joystick press
ebl:       .byte 0
ebr:       .byte 0
ebu:       .byte 0
ebd:       .byte 0
ebp:       .byte 0

maxp1gx:    .byte 0,0
maxp1gy:    .byte 0,0
maxp1gx_px: .byte 0,0
maxp1gy_px: .byte 0,0

// TODO: move to zero page
current_buffer:  .byte 0
frame_phase:     .byte 0
frame_tick:      .byte 0
animation_frame: .byte 0
animation_index: .byte 0

// bit7 - jumping
// bit6 - x direction         (0 = left, 1 = right)
// bit5 - moving horizontally (0 = false, 1 = true)
// bit4 - turning             (0 = false, 1 = true)
player_animation_flag: .byte 0

on_ground:                     .byte 0

sound_started:                 .byte 0
melody_v1_index:               .byte 0
melody_v1_dur_left:            .byte 0
melody_v2_index:               .byte 0
melody_v2_dur_left:            .byte 0
// melody_v3_index:               .byte 0
// melody_v3_dur_left:            .byte 0
melody_frames_until_16th:      .byte 0

current_sound_effect_freq_lo:          .byte 0
current_sound_effect_freq_hi:          .byte 0
current_sound_effect_ticks_left:       .byte 0
current_sound_effect_sweep_adder_lo:   .byte 0
current_sound_effect_sweep_adder_hi:   .byte 0
current_sound_effect_sweep_ticks_left: .byte 0

sound_effect_ready:
  .byte 0
sound_effect_index:
  .byte 0  

// VICE testing:
// Jump
// > .sound_effects_pulse_lo $00 $08 $15 $14 $41 $18 $0e $10 $a0 $01 $0f *
// > .sound_effects_pulse_lo $00 $08 $24 $06 $21 $00 $02 $14 $4c $00 $13
// > .sound_effects_pulse_lo $00 $08 $24 $88 $41 $00 $03 $20 $10 $00 $1f
// > .sound_effects_pulse_lo $00 $08 $25 $26 $41 $8f $0a $10 $a0 $00 $0f
// > .sound_effects_pulse_lo $00 $08 $25 $26 $41 $c3 $10 $10 $a0 $00 $0f
// > .sound_effects_pulse_lo $00 $08 $14 $14 $41 $18 $0e $10 $a0 $00 $0f
// > .sound_effects_pulse_lo $00 $08 $14 $18 $41 $18 $0e $14 $f0 $03 $13

//> .sound_effects_pulse_lo $00 $08 $15 $1f $41 $18 $0e $10 $a0 $00 $0f
pending_buffer_swap:
  .byte 0

pending_color_upper_swap:
  .byte 0

pending_color_lower_swap:
  .byte 0

current_irq:
  .byte 0
next_irq:
  .byte 0

raster_line:
  .byte 0,0

max_raster_line:
  .byte 0,0

// buffer of enemies to check when updating enemy movement,
// scrolling the screen, or doing collision detection.
enemies_buffer_min:       .byte 0
enemies_buffer_max:       .byte 0

enemy_collided_temp:      .byte 0
enemy_kills:              .byte 0

sprite_collisions_detected: .byte 0

bresenham_crossed_boundary:       .byte 0
bresenham_pixel_boundaries_count: .byte 0
bresenham_pixel_boundariesx:      .fill 64,0
bresenham_pixel_boundariesy:      .fill 64,0

num_lives:                .byte 0