#!/bin/sh
java -jar KickAss.jar office.asm -log bin/office_BuildLog.txt -o bin/office.prg -vicesymbols -showmem -odir bin && denise -attach9 ./office.d64 ./bin/office.prg
