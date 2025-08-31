// Devil's Dream
// C, F, G are sharp
// notes are 8ths unless specified
// E5 // quarter note
// A5, G#5, A5, E5, A5, G#5, A5, E5
// A5, G#5, A5, E5, F#5, E5, D5, C#5
// D5, F#5, B4, F#5, D5, F#5, B4, F#5
// D5, F#5, B4, F#5, A5, G#5, F#5, E5
// A5, G#5, A5, E5, A5, G#5, A5, E5
// A5, G#5, A5, E5, F#5, E5, D5, C#5
// D5, F#5, E5, D5, C#5, A4, B4, A4
// E4, A4, A4, E5 // quarter notes
melody_v1_attack_decay:     .byte $48
melody_v1_sustain_release:  .byte $B6
melody_v1_control:          .byte %00110001
// melody_v1:
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2

//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_CS4_HF, NOTE_CS4_LF, 2

//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_B3_HF, NOTE_B3_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_B3_HF, NOTE_B3_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2

//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_B3_HF, NOTE_B3_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2

//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2

//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_GS4_HF, NOTE_GS4_LF, 2
//   .byte NOTE_A4_HF, NOTE_A4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_CS4_HF, NOTE_CS4_LF, 2

//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_FS4_HF, NOTE_FS4_LF, 2
//   .byte NOTE_E4_HF, NOTE_E4_LF, 2
//   .byte NOTE_D4_HF, NOTE_D4_LF, 2
//   .byte NOTE_CS4_HF, NOTE_CS4_LF, 2
//   .byte NOTE_A3_HF, NOTE_A3_LF, 2
//   .byte NOTE_B3_HF, NOTE_B3_LF, 2
//   .byte NOTE_A3_HF, NOTE_A3_LF, 2

//   .byte NOTE_E3_HF, NOTE_E3_LF, 4
//   .byte NOTE_A3_HF, NOTE_A3_LF, 4
//   .byte NOTE_A3_HF, NOTE_A3_LF, 4
//   .byte NOTE_E4_HF, NOTE_E4_LF, 4
// melody_v1_end:
melody_v1:
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2

  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_CS3_HF, NOTE_CS3_LF, 2

  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_B2_HF, NOTE_B2_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_B2_HF, NOTE_B2_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2

  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_B2_HF, NOTE_B2_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2

  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2

  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_GS3_HF, NOTE_GS3_LF, 2
  .byte NOTE_A3_HF, NOTE_A3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_CS3_HF, NOTE_CS3_LF, 2

  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_FS3_HF, NOTE_FS3_LF, 2
  .byte NOTE_E3_HF, NOTE_E3_LF, 2
  .byte NOTE_D3_HF, NOTE_D3_LF, 2
  .byte NOTE_CS3_HF, NOTE_CS3_LF, 2
  .byte NOTE_A2_HF, NOTE_A2_LF, 2
  .byte NOTE_B2_HF, NOTE_B2_LF, 2
  .byte NOTE_A2_HF, NOTE_A2_LF, 2

  .byte NOTE_E2_HF, NOTE_E2_LF, 4
  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_E3_HF, NOTE_E3_LF, 4
melody_v1_end:

// melody_v2_attack_decay:    .byte $26
// melody_v2_sustain_release: .byte $74
melody_v2_attack_decay:     .byte $25
melody_v2_sustain_release:  .byte $64
melody_v2_control:          .byte %00110001
melody_v2:
  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_CS2_HF, NOTE_CS2_LF, 4
  .byte NOTE_E2_HF, NOTE_E2_LF, 4
  .byte NOTE_CS2_HF, NOTE_CS2_LF, 4

  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_REST, NOTE_REST, 4
  .byte NOTE_CS3_HF, NOTE_CS3_LF, 4
  .byte NOTE_REST, NOTE_REST, 4

  .byte NOTE_D3_HF, NOTE_D3_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4
  .byte NOTE_B2_HF, NOTE_B2_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4

  .byte NOTE_D3_HF, NOTE_D3_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4
  .byte NOTE_E3_HF, NOTE_E3_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4

  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_A3_HF, NOTE_A3_LF, 4
  .byte NOTE_E2_HF, NOTE_E2_LF, 4
  .byte NOTE_A3_HF, NOTE_A3_LF, 4

  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_REST, NOTE_REST, 4
  .byte NOTE_CS3_HF, NOTE_CS3_LF, 4
  .byte NOTE_REST, NOTE_REST, 4

  .byte NOTE_D3_HF, NOTE_D3_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4
  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4

  .byte NOTE_FS2_HF, NOTE_FS2_LF, 4
  .byte NOTE_B3_HF, NOTE_B3_LF, 4
  .byte NOTE_A2_HF, NOTE_A2_LF, 4
  .byte NOTE_REST, NOTE_REST, 4
melody_v2_end:

melody_v3_attack_decay:     .byte $48
melody_v3_sustain_release:  .byte $B6
melody_v3_control:          .byte %00100001
melody_v3:
  .byte 0,0,4
melody_v3_end: