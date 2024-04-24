class_name Rotation

const rotationX = Vector2i(0, -1)
const rotationY = Vector2i(1, 0)

var kickTable3: Array = [
	[Vector2i(0,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,0)],
	[Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(0,-2), Vector2i(1,-2)],
	[Vector2i(0,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,0)],
	[Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,-2), Vector2i(-1,-2)]
]

var kickTable5: Array = [
	[Vector2i(0,0), Vector2i(-1,0), Vector2i(+2,0), Vector2i(-1,0), Vector2i(+2,0)],
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,-1), Vector2i(0,2)],
	[Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-2,-1), Vector2i(1,0), Vector2i(-2,0)],
	[Vector2i(0,-1), Vector2i(0,-1), Vector2i(0,-1), Vector2i(0,1), Vector2i(0,-2)]
]

var kickTableSquare: Array = [
	[Vector2i(0,0)],
	[Vector2i(0,1)],
	[Vector2i(-1,1)],
	[Vector2i(-1,0)]
]

func rotation(piece:Piece, direction: int = 1):
	var rotated_piece = []
	for m in piece.piece_blocks:
		var mX = m[0]
		var mY = m[1]
		var newX = (rotationX.x * direction * mX) + (rotationX.y * direction * mY)
		var newY = (rotationY.x * direction * mX) + (rotationY.y * direction * mY)
		rotated_piece.append(Vector2i(newX, newY))
	return rotated_piece
	
	

