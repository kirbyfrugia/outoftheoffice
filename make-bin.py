# takes an assembled binary and prepends 32KB of empty data to it. Makes it easier to view
# the file in a hex editor.
empty = bytearray([0x00] * 32768)

with open("./bin/office.bin", "rb") as in_file:
	data = in_file.read()

empty.extend(data)

with open("./bin/office-padded.bin", "wb") as out_file:
	out_file.write(empty)
