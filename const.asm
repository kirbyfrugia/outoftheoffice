
.const scrcol0   = 0
.const scrwidth  = 40
.const scrrow0   = 0
.const scrheight = 22

.const sprmc0    = $01
.const sprmc1    = $00

.const p1width         = 14
.const p1height        = 20
// .const P1_STARTX       = 105
.const P1_STARTX       = 8
.const P1_STARTY       = 140

.const P1_COLLISION_X0 = 2
.const P1_COLLISION_X1 = 7
.const P1_COLLISION_X2 = 11
.const P1_COLLISION_Y0 = 1
.const P1_COLLISION_Y1 = 8
.const P1_COLLISION_Y2 = 16
.const P1_COLLISION_Y3 = 19
// how many screen chars might be collidable with p1
.const p1spanwidth  = 3
.const p1spanheight = 4
// at what points in the p1 movement do we scroll the screen
// scrollmax must be a chunk below 255
.const scrollmin    = 94
.const scrollmax    = 226

.const RASTER_HUD         = $e2 // 3 char rows before bottom border
.const RASTER_HUD_DONE    = $fa
.const RASTER_BUFFER_SWAP = $00
// Lower half of screen memory starts at $82
// Use the update_max_raster_line routine to determine where to start this.
// Should start soon after we've finished moving the upper screen memory
.const RASTER_COLOR_LOWER = $4a
// .const RASTER_COLOR_LOWER = $4c // best so far
// .const RASTER_COLOR_LOWER = $5c // 2nd best so far
// .const RASTER_COLOR_LOWER = $7c // 3rd best so far
// .const RASTER_COLOR_LOWER = $81


.const HUD_ROW_0_FB     = 1904
.const HUD_ROW_0_BB     = 2928
.const HUD_ROW_1_FB     = 1944
.const HUD_ROW_1_BB     = 2968
.const HUD_ROW_2_FB     = 1984
.const HUD_ROW_2_BB     = 3008

.const HUD_ROW_0_CLR    = 56176
.const HUD_ROW_1_CLR    = 56216
.const HUD_ROW_2_CLR    = 56256

.const SPRITE_PTR_FIRST_B1    =    48  // sprite pointer at which sprite 0 starts from batch 1
.const P1_FACING_RIGHT_OFFSET = SPRITE_PTR_FIRST_B1+0
.const P1_FACING_LEFT_OFFSET  = SPRITE_PTR_FIRST_B1+6
.const P1_ENEMY_ATTACHED      = SPRITE_PTR_FIRST_B1+12

.const MAX_ENEMY_BUFFER_SIZE  = 10

.const SPRITE_PTR_FIRST_B2    =    128 // sprite pointer at which sprite 0 starts from batch 2
.const ENEMY_ATTACKING_SMOKE  = SPRITE_PTR_FIRST_B2+6

.const SPRITE_PTR_BASE_FB  = $07f8 // sprite pointers for the front buffer
.const SPRITE_PTR_BASE_BB  = $0bf8 // sprite pointers for the back buffer
.const SPRITE_XPOS_BASE    = $d000
.const SPRITE_YPOS_BASE    = $d001
.const SPRITE_MSB          = $d010
.const VIC_VCONTROL_REG    = $d011
.const VIC_RW_RASTER       = $d012
.const SPRITE_ENABLE       = $d015
.const VIC_HCONTROL_REG    = $d016
.const VIC_MEM_CONTROL_REG = $d018
.const VIC_IRQ_FLAG        = $d019
.const VIC_IRQ_MASK        = $d01a
.const SPRITE_MC_MODE      = $d01c
.const SPRITE_COLLISION    = $d01e
.const BORDER_COLOR        = $d020
.const BG_COLOR0           = $d021
.const BG_COLOR1           = $d022
.const SPRITE_MC0          = $d025
.const SPRITE_MC1          = $d026
.const SPRITE_COLOR_BASE   = $d027

.const SID_BASE        = 54272

.const COLOR_HUD_BG    = 6
.const COLOR_HUD_TITLE = 13
.const COLOR_HUD_TEXT  = 3
.const COLOR_BG        = 12
.const COLOR_BORDER    = 0
.const VOICE1          = 54272
.const VOICE1_LF       = 54272
.const VOICE1_HF       = 54273
.const VOICE1_CONTROL  = 54276
.const VOICE1_ENV_AD   = 54277
.const VOICE1_ENV_SR   = 54278

.const VOICE2          = 54279
.const VOICE2_LF       = 54279
.const VOICE2_HF       = 54280
.const VOICE2_CONTROL  = 54283
.const VOICE2_ENV_AD   = 54284
.const VOICE2_ENV_SR   = 54285

.const VOICE3          = 54286
.const VOICE3_LF       = 54286
.const VOICE3_HF       = 54287
.const VOICE3_PULSE_LO = 54288
.const VOICE3_PULSE_HI = 54289
.const VOICE3_CONTROL  = 54290
.const VOICE3_ENV_AD   = 54291
.const VOICE3_ENV_SR   = 54292

.const SID_FILT_CUTOFF_LB = 54293
.const SID_FILT_CUTOFF_HB = 54294
.const SID_FILT_RESONANCE = 54295
.const SID_FILT_VOL       = 54296

.const NOTE_REST   = 0
.const NOTE_A1_HF  = 3
.const NOTE_A1_LF  = 134
.const NOTE_E1_HF  = 2
.const NOTE_E1_LF  = 163
.const NOTE_A2_HF  = 7
.const NOTE_A2_LF  = 12
.const NOTE_B2_HF  = 7
.const NOTE_B2_LF  = 233
.const NOTE_CS2_HF = 4
.const NOTE_CS2_LF = 112
.const NOTE_E2_HF  = 5
.const NOTE_E2_LF  = 71
.const NOTE_FS2_HF = 5
.const NOTE_FS2_LF = 237
.const NOTE_A3_HF  = 14
.const NOTE_A3_LF  = 24
.const NOTE_B3_HF  = 15
.const NOTE_B3_LF  = 210
.const NOTE_C3_HF  = 8
.const NOTE_C3_LF  = 97
.const NOTE_CS3_HF = 8
.const NOTE_CS3_LF = 225
.const NOTE_D3_HF  = 9
.const NOTE_D3_LF  = 104
.const NOTE_E3_HF  = 10
.const NOTE_E3_LF  = 143
.const NOTE_F3_HF  = 11
.const NOTE_F3_LF  = 48
.const NOTE_G3_HF  = 12
.const NOTE_G3_LF  = 143
.const NOTE_FS3_HF = 11
.const NOTE_FS3_LF = 218
.const NOTE_GS3_HF = 13
.const NOTE_GS3_LF = 78
.const NOTE_A4_HF  = 28
.const NOTE_A4_LF  = 49
.const NOTE_B4_HF  = 31
.const NOTE_B4_LF  = 165
.const NOTE_C4_HF  = 16
.const NOTE_C4_LF  = 195
.const NOTE_CS4_HF = 17
.const NOTE_CS4_LF = 195
.const NOTE_D4_HF  = 18
.const NOTE_D4_LF  = 209
.const NOTE_E4_HF  = 21
.const NOTE_E4_LF  = 31
.const NOTE_F4_HF  = 22
.const NOTE_F4_LF  = 96
.const NOTE_FS4_HF = 23
.const NOTE_FS4_LF = 181
.const NOTE_G4_HF  = 25
.const NOTE_G4_LF  = 30
.const NOTE_GS4_HF = 26
.const NOTE_GS4_LF = 156
.const NOTE_A5_HF  = 56
.const NOTE_A5_LF  = 99
.const NOTE_CS5_HF = 35
.const NOTE_CS5_LF = 134
.const NOTE_C5_HF  = 33
.const NOTE_C5_LF  = 135
.const NOTE_D5_HF  = 37
.const NOTE_D5_LF  = 162
.const NOTE_E5_HF  = 42
.const NOTE_E5_LF  = 62
.const NOTE_FS5_HF = 47
.const NOTE_FS5_LF = 107
.const NOTE_GS5_HF = 53
.const NOTE_GS5_LF = 57


// //////////////////////////////////////////////////////////////////////////////
// // warning: these areas of memory are used for file loading and saving.
// // Do not change the order or size of any of it.
// //////////////////////////////////////////////////////////////////////////////
// .const filedatas    = $2000
// .const tiles        = $2000
// .const tsdata       = $2800
// .const chrtm        = $2900
// .const chrtmrun0    = $2900
// .const chrtmrunlast = $2902
// .const chrtmcolc    = $2904
// .const mdtm         = $2906
// .const mdtmrun0     = $2906
// .const mdtmrunlast  = $2908
// .const mdtmcolc     = $290a
// .const bgclr        = $290c
// .const bgclr1       = $290d
// .const bgclr2       = $290e
// .const filedatae    = $290e

// .const chrtmdatas   = $4000
// .const chrtmdatae   = $5fff
// .const mdtmdatas    = $6000
// .const mdtmdatae    = $7fff
// //////////////////////////////////////////////////////////////////////////////
// // see warning above
// //////////////////////////////////////////////////////////////////////////////


