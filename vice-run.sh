#!/bin/sh
java -jar KickAss.jar office.asm -log bin/office_BuildLog.txt -o bin/office.prg -vicesymbols -showmem -odir bin && x64sc -logfile ./log/vicelog.txt -moncommands ./bin/office.vs -8 ./bin/office.d64 ./bin/office.prg
