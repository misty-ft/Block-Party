class_name Piece

var piece_name: String # The name of the piece which would show in-game.
var piece_color: int # The color of the piece to show utility
var piece_blocks: Array
var piece_isSquare: bool = false
var piece_rotIndex: int = 0

func bounds():
	var tileMinX = 0 # leftmost position
	var tileMaxX = 0 # rightmost position
	var tileMinY = 0 # topmost position
	var tileMaxY = 0 # bottommost position
	
	# Finding how far in each direction the block goes
	for m in piece_blocks:
		if m[0] < tileMinX:
			tileMinX = m[0]
		if m[0] > tileMaxX:
			tileMaxX = m[0]
		if m[1] < tileMinY:
			tileMinY = m[1]
		if m[1] > tileMaxY:
			tileMaxY = m[1]
	return [tileMinX, tileMaxX, tileMinY, tileMaxY]

func dimensions():
	# Used in calculations to render next and hold queues.
	var b = bounds()
	var w = b[1] - b[0] + 1
	var h = b[3] - b[2] + 1
	return Vector2i(w, h)
	
func center():
	
	# Pieces are centered around (0, 0).
	# For odd width pieces, the minos should extend in both directions at equal lengths.
	# For even width pieces, the minos should bias towards the right.
	# For example, I4 is allowed to have a segment at (2,0).
	# Same goes for height. For even heights, the blocks bias upwards (negative).
	
	var b = bounds()
	
	while b[0] + b[1] > 1:
		for n in piece_blocks:
			n.X -= 1
	while b[0] + b[1] < 0:
		for n in piece_blocks:
			n.X += 1
	
	while b[2] + b[3] > 0:
		for n in piece_blocks:
			n.Y -= 1
	while b[2] + b[3] < -1:
		for n in piece_blocks:
			n.Y += 1
			

func bottom():
	
	var b = bounds()
	return b[3]
	
