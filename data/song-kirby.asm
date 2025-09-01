// Kirby's song
// Basic arpeggio
// C4,E4,G4 x 4, 8th notes
// F4,A4,C4 x 4, 8th notes
// G4,B4,D5 x 4, 8th notes
// repeat
melody_v1:
  .byte NOTE_C4_HF, NOTE_C4_LF, 2
  .byte NOTE_E4_HF, NOTE_E4_LF, 1
  .byte NOTE_G4_HF, NOTE_G4_LF, 1
  .byte NOTE_E4_HF, NOTE_E4_LF, 1
  .byte NOTE_G4_HF, NOTE_G4_LF, 1
  .byte NOTE_C4_HF, NOTE_C4_LF, 2
  .byte NOTE_E4_HF, NOTE_E4_LF, 2
  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_C4_HF, NOTE_C4_LF, 2
  .byte NOTE_E4_HF, NOTE_E4_LF, 2
  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_C4_HF, NOTE_C4_LF, 2
  .byte NOTE_E4_HF, NOTE_E4_LF, 1
  .byte NOTE_G4_HF, NOTE_G4_LF, 1
  .byte NOTE_E4_HF, NOTE_E4_LF, 1
  .byte NOTE_G4_HF, NOTE_G4_LF, 1

  .byte NOTE_F4_HF, NOTE_F4_LF, 2
  .byte NOTE_A4_HF, NOTE_A4_LF, 2
  .byte NOTE_C5_HF, NOTE_C5_HF, 2
  // .byte NOTE_A4_HF, NOTE_A4_LF, 1
  // .byte NOTE_C5_HF, NOTE_C5_HF, 1
  // .byte NOTE_A4_HF, NOTE_A4_LF, 1
  // .byte NOTE_C5_HF, NOTE_C5_HF, 1
  .byte NOTE_F4_HF, NOTE_F4_LF, 2
  .byte NOTE_A4_HF, NOTE_A4_LF, 2
  .byte NOTE_C5_HF, NOTE_C5_HF, 2
  .byte NOTE_F4_HF, NOTE_F4_LF, 2
  .byte NOTE_A4_HF, NOTE_A4_LF, 2
  .byte NOTE_C5_HF, NOTE_C5_HF, 2
  .byte NOTE_F4_HF, NOTE_F4_LF, 2
  .byte NOTE_A4_HF, NOTE_A4_LF, 2
  .byte NOTE_C5_HF, NOTE_C5_HF, 2
  // .byte NOTE_A4_HF, NOTE_A4_LF, 1
  // .byte NOTE_C5_HF, NOTE_C5_HF, 1
  // .byte NOTE_A4_HF, NOTE_A4_LF, 1
  // .byte NOTE_C5_HF, NOTE_C5_HF, 1

  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_B4_HF, NOTE_B4_LF, 1
  .byte NOTE_D5_HF, NOTE_D5_LF, 1
  .byte NOTE_B4_HF, NOTE_B4_LF, 1
  .byte NOTE_D5_HF, NOTE_D5_LF, 1
  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_B4_HF, NOTE_B4_LF, 2
  .byte NOTE_D5_HF, NOTE_D5_LF, 2
  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_B4_HF, NOTE_B4_LF, 2
  .byte NOTE_D5_HF, NOTE_D5_LF, 2
  .byte NOTE_G4_HF, NOTE_G4_LF, 2
  .byte NOTE_B4_HF, NOTE_B4_LF, 1
  .byte NOTE_D5_HF, NOTE_D5_LF, 1
  .byte NOTE_B4_HF, NOTE_B4_LF, 1
  .byte NOTE_D5_HF, NOTE_D5_LF, 1
melody_v1_end:

melody_v2:
  .byte NOTE_A3_HF, NOTE_A3_LF, 24
  .byte NOTE_F3_HF, NOTE_F3_LF, 24
  .byte NOTE_G3_HF, NOTE_G3_LF, 24
melody_v2_end:

// melody_v3:
//   .byte 0,0,72
// melody_v3_end:

.const melody_v1_attack_decay    = $35
.const melody_v1_sustain_release = $A7
.const melody_v1_control         = %00010001
.const melody_v2_attack_decay    = $35 // $25
.const melody_v2_sustain_release = $A7 // $64
.const melody_v2_control         = %00010001
// .const melody_v3_attack_decay    = $48
// .const melody_v3_sustain_release = $B6
// .const melody_v3_control         = %00100001

.const melody_cutoff_filter_hi = %00000010
.const melody_cutoff_filter_lo = %11111111
.const melody_filter_resonance = %00000010 // apply filter to voice 2
.const melody_filter_volume    = %01001111 // high pass filter, full volume
.const melody_tempo            = 10        // N frames between 16th notes