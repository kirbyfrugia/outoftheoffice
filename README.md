# Out of the Office

A 2D platformer game for the Commodore 64. Note, if you're reading this code, please don't judge and please don't consider this an example for how to program assembly. This was a learning exercise to learn 6502 assembly and to have fun. It was my first game and my first serious assembly program.

# Pre-requisites

* Install [denise](https://sourceforge.net/projects/deniseemu/) or [vice](https://vice-emu.sourceforge.io/windows.html) and add to path
* Install java
* Install [KickAss (C64) VS Code extension](https://marketplace.visualstudio.com/items?itemName=CaptainJiNX.kickass-c64)
* To edit the levels, install [CharPad C64 Pro](https://subchristsoftware.itch.io/charpad-c64-pro)
* To edit the sprites, install [SpritePad 64 Pro](https://subchristsoftware.itch.io/spritepad-c64-pro)

# Building
```./assemble.sh```

# Running

Note: this was built for NTSC. It'll work in PAL, but setting your emulator to NTSC will work better.

Run with denise:
```./denise-run.sh```

Run with vice:
```./vice-run.sh```

# Updating the sprites

Edit data/spritesbatch1.spd in spritepad. Export All as Text from spritepad to spritesbatch1.asm. Then:
```./charpad-to-kickass-sprites.sh spritesbatch1.asm```

Do the same for spritesbatch2

# Updating levels
Edit data/level1.ctm in charpad. Export All as Text from charpad. Then:
```./charpad-to-kickass-level.sh level1.asm```

# Some helpful tools