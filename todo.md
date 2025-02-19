
# Todo


# Optimizations

* When we have extra cycles, create arrays of the tiles to the right and left for when we need to redraw the screen. Keep them in memory so that portion is faster. But make sure this is actually faster. Since we can move at most about 4 pixels per frame, we could set a flag indicating a redraw is needed. If it's not set, determine the edges in memory somewhere. If it's set, redraw the map.