# Out of the Office

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

Edit data/sprites.asm in spritepad. After saving any changes, run ./data/charpad-to-kickass-sprites.sh

# Some helpful tools