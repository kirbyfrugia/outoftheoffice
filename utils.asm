
// copy one region of memory to another, assumes num bytes > 0
// inputs
//   $fb src lo byte
//   $fc src hi byte
//   $fd dest lo byte
//   $fe dest hi byte
//   $bb num bytes lo byte
//   $bc num bytes hi byte
copy:
  pha
  tya
  pha

  ldy #0
copyl:
  lda ($fb),y
  sta ($fd),y

  lda $bb
  sec
  sbc #1
  sta $bb
  lda $bc
  sbc #0
  sta $bc
  bne copyln
  lda $bb
  bne copyln
  beq copyld
copyln:
  iny
  bne copyl
  inc $fc
  inc $fe
  jmp copyl
copyld:
  pla
  tay
  pla  
  rts

// copies address to loc in zpb
.macro ToZPB(lo,hi,zpblo) {
  lda #lo
  sta zpblo
  lda #hi
  sta zpblo+1
}

// ADD MACRO
//   lda @P1
//   clc
//   adc @P2
//   sta @P1
//   ENDM

// SUB MACRO
//   lda @P1
//   sec
//   sbc @P2
//   sta @P1
//   ENDM

// used to "debounce" events.
// triggers if the key or button 
// is held for 6 frames or it just
// got pressed.
// @P1 byte used for event buffer
// @P2 label to jsr to if triggered
.macro Debounce(ebbyte,jsrlabel) {
  // if pressed for six frames
  // or first press, accept//
  lda ebbyte
  and #%00111111
  beq dbh
  and #%00111111
  cmp #%00111110
  beq dbh
  bne dbno 
dbh:
  lda #%11111110
  sta ebbyte
  jsr jsrlabel
dbno:
}

// updates the address in zpb0
// to the next row
nscreenrow:
  pha
  lda zpb0
  clc
  adc #40
  sta zpb0
  bcc nscreenrowd
  inc zpb1  
nscreenrowd:
  pla
  rts

// @P1 key code
// @P2 event buffer byte
// @P3 label for line following this
.macro InKBD(keycode,ebbyte,jmplabel) {
  cmp #keycode
  bne koff
  clc
  rol ebbyte
  jmp jmplabel
koff:
  sec
  rol ebbyte
}

//logs a hexit value A to zpb0 offset
//by Y
//Y will be incremented 
loghexit:
  pha
  ror
  ror
  ror
  ror
  and #%00001111
  cmp #10
  bcc lhd1
  bcs lhcd1
lhd1:
  clc
  adc #48 //zero
  sta (zpb0),Y
  jmp loghexit2
lhcd1:
  clc
  adc #1 //A
  sec
  sbc #10
  sta (zpb0),Y
loghexit2:
  iny
  pla
  pha
  and #%00001111
  cmp #10
  bcc lhd2
  bcs lhcd2
lhd2:
  clc
  adc #48 //zero
  sta (zpb0),Y
  jmp loghexitd
lhcd2:
  clc
  adc #1 //A
  sec
  sbc #10
  sta (zpb0),Y
loghexitd:
  pla
  rts

// prints null terminated
// at zpb0 to location zpb2
ps:
  pha
  tya
  pha
  ldy #0
psl:
  lda (zpb0),Y
  beq psld
  sta (zpb2),Y
  iny
  bne psl
psld:
  pla
  tay
  pla
  rts

// colors null terminated string
// at zpb0 to location zpb2
// to color in X.
cs:
  pha
  tya
  pha
  ldy #0
csl:
  lda (zpb0),Y
  beq csld
  txa
  sta (zpb2),Y
  iny
  bne csl
csld:
  pla
  tay
  pla
  rts
 

// loads a file into memory
// inputs:
//   zpb0/zpb1 - location to load file
//   fname - load with the name of the file to load
//   fnamelen - length of file name
//   fdev - device number
// outputs:
//   fstatus - 0 if load successful, error otherwise
// note: A,X,Y all modified
fload:
  // restore default i/o
  jsr $ffcc 

  // set the file name
  lda fnamelen
  ldx #<fname
  ldy #>fname
  jsr $ffbd

  // set device info
  lda #15
  ldx fdev
  ldy #0
  jsr $ffba

  clc // not sure if necessary, but not sure if $ffc0 sets carry
  // open the file
  jsr $ffc0
  bcs flerr
  jsr $ffb7
  bne flerr

  // prepare for input
  ldx #15
  jsr $ffc6 //chkin
  bcs flerr

  ldy #0
fll:
  jsr $ffcf
  sta fbyte
  jsr $ffb7
  cmp #64 // eof
  beq flsucc
  and #%10111111
  bne flerr
  lda fbyte
  sta (zpb0),y
  iny
  bne fll
  inc zpb1
  bne fll
flsucc:
  // process last byte
  lda fbyte
  sta (zpb0),y
  lda #0
  sta fstatus
  beq fld
flerr:
  // todo something
  sta fstatus
fld:
  // close the file
  lda #15
  jsr $ffc3
  // clear all channels
  jsr $ffcc 
  rts


// saves a section of memory to a file
// inputs:
//   zpb0/zpb1 - start memory location
//   zpb2/zpb3 - end memory location
//   fname - load with the name of the file to load
//   fnamelen - length of file name
//   fdev - device number
// outputs:
//   fstatus - 0 if save successful, error otherwise
// note: A,X,Y all modified
fsave:
  // restore default i/o
  jsr $ffcc 

  // set the file name
  lda fnamelen
  ldx #<fname
  ldy #>fname
  jsr $ffbd

  // set device info
  lda #15
  ldx fdev
  ldy #1
  jsr $ffba

  clc // not sure if necessary, but not sure if $ffc0 sets carry
  // open the file
  jsr $ffc0
  bcs fserr
  jsr $ffb7
  bne fserr

  // prepare for output
  ldx #15
  jsr $ffc9
  bcs fserr

  ldy #0
fsl:
  lda (zpb0),y
  jsr $ffd2
  sta fbyte
  jsr $ffb7
  bne fserr

  lda zpb0
  cmp zpb2
  bne fslco
  lda zpb1
  cmp zpb3
  bne fslco
  beq fssucc
fslco:
  lda zpb0
  clc
  adc #1
  sta zpb0
  lda zpb1
  adc #0
  sta zpb1
  bne fsl
fssucc:
  lda #0
  sta fstatus
  beq fsd
fserr:
  // todo something
  sta fstatus
fsd:
  // close the file
  lda #15
  jsr $ffc3
  // clear all channels
  jsr $ffcc 
  rts




fname:     .fill 16,0
fnamelen:  .byte 0
fdev:      .byte 0
fbyte:     .byte 0
fstatus:   .byte 0

