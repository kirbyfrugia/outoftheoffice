
# Todo


# Optimizations

## Idea
When we have extra cycles, create arrays of the tiles to the right and left for when we need to redraw the screen. Keep them in memory so that portion is faster. But make sure this is actually faster. Since we can move at most about 4 pixels per frame, we could set a flag indicating a redraw is needed. If it's not set, determine the edges in memory somewhere. If it's set, redraw the map.

# Data

The charset attribs from charpad is 1 byte per character.
The upper nybble is the charset material.
The lower nybble is the character color.

We'll use the upper nybble to keep collision information. Each bit corresponds to whether a side of the char is collidable.

We'll ignore the lower nybble for now but might decide to use it later.

Instead, we'll have the colors stored by map tile. So, each map-tile would have 1 byte of data.
Bit 7,6,5 unused
Bit 4, indicates whether the tile is collidable at this location in the map
Bits 3-0 are the color.

The only downside to this approach is that it's not what charpad does by default. So we'll have to apply the color
outside of charpad by hand. We could make a file format that's a csv file that stores colors.
row,col,color
And then have a python script that generates that color.