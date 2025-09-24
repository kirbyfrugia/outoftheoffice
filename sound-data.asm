// sound effects table
// indices:
//   0 - jump
//   1 - hitting ceiling
//   2 - squishing enemies
//   3 - player death
//   4 - player deat alternate
sound_effects_pulse_lo:
  .byte $00, $00, $00, $00, $00
sound_effects_pulse_hi:
  .byte $08, $05, $00, $00, $08
sound_effects_attack_decay:
  .byte $15, $08, $06, $0a, $0c
sound_effects_sustain_release:
  .byte $14, $03, $03, $06, $08
sound_effects_waveform:
  .byte %01000001
  .byte %01000001
  .byte %10000001
  .byte %10000001
  .byte %01000001
sound_effects_freq_lo:
  .byte $18, $00, $00, $00, $00
sound_effects_freq_hi:
  .byte $0e, $07, $16, $18, $18
sound_effects_num_ticks:
  .byte $14, $14, $14, $14, $20
sound_effects_sweep_adder_lo:
  .byte $a0, $f4, $18, $f4, $d0
sound_effects_sweep_adder_hi:
  .byte $01, $ff, $00, $ff, $ef
sound_effects_sweep_num_ticks:
  .byte $0f, $0f, $14, $14, $20
