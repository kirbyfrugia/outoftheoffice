// TODO: convert from var to const
.var zpb0 = $fb
.var zpb1 = $fc
.var zpb2 = $fd
.var zpb3 = $fe

.var zpb4 = $39
.var zpb5 = $3a
.var zpb6 = $3b
.var zpb7 = $3c

.var scrcol0   = 0
.var scrwidth  = 40
.var scrrow0   = 0
.var scrheight = 22

.var sprmc0    = $01
.var sprmc1    = $00

.var p1width      = 14
.var p1height     = 20
// how many screen chars might be collidable with p1
.var p1spanwidth  = 3
.var p1spanheight = 4
// at what points in the p1 movement do we scroll the screen
// scrollmax must be a chunk below 255
.var scrollmin    = 94
.var scrollmax    = 226

.const RASTER_LAST3    = $e2
.const RASTER_VBLANK   = $fa

.const SID_BASE        = 54272
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
// .var filedatas    = $2000
// .var tiles        = $2000
// .var tsdata       = $2800
// .var chrtm        = $2900
// .var chrtmrun0    = $2900
// .var chrtmrunlast = $2902
// .var chrtmcolc    = $2904
// .var mdtm         = $2906
// .var mdtmrun0     = $2906
// .var mdtmrunlast  = $2908
// .var mdtmcolc     = $290a
// .var bgclr        = $290c
// .var bgclr1       = $290d
// .var bgclr2       = $290e
// .var filedatae    = $290e

// .var chrtmdatas   = $4000
// .var chrtmdatae   = $5fff
// .var mdtmdatas    = $6000
// .var mdtmdatae    = $7fff
// //////////////////////////////////////////////////////////////////////////////
// // see warning above
// //////////////////////////////////////////////////////////////////////////////


