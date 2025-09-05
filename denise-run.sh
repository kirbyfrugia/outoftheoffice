#!/bin/sh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
java -jar KickAss.jar office.asm -log bin/office_BuildLog.txt -o bin/office.prg -vicesymbols -showmem -odir bin && denise -attach8 $SCRIPTPATH/bin/office.d64 bin/office.d64:office
#  $SCRIPTPATH/bin/office.d64:office.prg