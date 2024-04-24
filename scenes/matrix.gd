extends Node2D

# board dimensions, used for calculating spawn location

var rows: int = 20
var spawnRowOffset = 0
var columns: int = 10

# spawn location

@warning_ignore("integer_division")
var pieceX = int(floor((columns-1)/2))
var pieceY = spawnRowOffset

var queue: Array = []

# active piece and where it is located on the matrix

var active_piece: Piece = Piece.new()
var activePos: Vector2i = Vector2i(0,0)
var rotIndex: int = 0
var rotatedThisFrame: bool = false

# hold queue

var held_piece = null
var holdUsed: bool = false

# layering for painting pieces onto the field

const board_layer = 0
const active_layer = 1

# Counters for movement logic

var global_Delay = 0
var gravity_Count = 0
var gravity_isActive = true
var piece_isActive: bool = true
var rotationTable: Rotation = Rotation.new()

# lastAction keeps track of what actions were performed within the matrix.
# 1: Gravity
# 2: Horizontal Movement
# 3: Rotation
var lastAction = 0

# lastDelay keeps track of what caused the game logic to pause.
# 1: spawn delay
# 2: clear delay
# 3: hold was used (not a delay)
# 4: new game countdown
var lastDelay = 0

var lastPieceIsSpin: bool = false
var lastPieceClears = 0
var linesCleared = []

# Below will be groups of frame datas. This is assuming a framerate of 60FPS.

# The framedata for game logic.
# The default numbers listed here will be for the basic speed level.
var lock_delay = .5
var clear_delay = .2 # aka line clear delay, adds to spawn delay
var spawn_delay = .05 # aka ARE
var gravity:float = 2
var fast_drop_factor = 20  # 10

# pDisplay stores the current piece next 5 pieces and in the following order:
# [0] current piece, [1-5] Next Queues 1-5
var pDisplay: Array = [null, null, null, null, null, null]

func fieldCollision(piece: Piece, piecePos: Vector2i, relativeCell: Vector2i):
	# checks if any parts of the piece will collide with either another block or the matrix wall.
	# If it returns true, that piece will collide with an object.
	# Generally looking for a false response to approve movement.
	for m in piece.piece_blocks:
		var mX = piecePos.x + m.x
		var mY = piecePos.y + m.y
		var mino = Vector2i(mX, mY)
		#print(mino)
		var collisionTile = mino + relativeCell
		#print($field.get_cell_atlas_coords(0,collisionTile))
		if $field.get_cell_source_id(0,collisionTile) != -1:
			return true
		if collisionTile.x < 0 or collisionTile.x >= columns or collisionTile.y >= rows:
			return true
	return false

func draw_matrix(width: int = 10, height: int = 20):
	for h in range(height+1):
		$field.set_cell(3, Vector2i(-1, h), 2, Vector2i(0, 0))
		$field.set_cell(3, Vector2i(width, h), 2, Vector2i(2, 0))
	for w in range(width):
		$field.set_cell(3, Vector2i(w, height), 2, Vector2i(1, 1))
	$field.set_cell(3, Vector2i(-1, height), 2, Vector2i(0, 1))
	$field.set_cell(3, Vector2i(width, height), 2, Vector2i(2, 1))
	for H in range(height):
		for W in range(width):
			$field.set_cell(3, Vector2i(W, H), 2, Vector2i(1, 0))
	

func update_queue_display(queueData: Array = queue):
	
	$"Next Queue and Hold/Next Queue".clear()
	$"Next Queue and Hold/Hold Queue".clear()
	
	$"Next Queue and Hold/Next Queue".position = Vector2i(32*(columns - 10),-324)
	
	var qHeight = 0
	
	for i in range(1, 6):
		var p = queueData[i]
		var pHeight = p.dimensions().y
		qHeight += pHeight
		var xOffset = 0
		if p.bounds()[0] < -1:
			xOffset = p.bounds()[0] + 1
		
		paint_piece(p, Vector2i(9 - xOffset, qHeight - p.bottom()), $"Next Queue and Hold/Next Queue", 1, false)
		
		qHeight += 1
		
	var holdOffset = 0
	if held_piece != null:
		if held_piece.bounds()[1] > 1:
			holdOffset = held_piece.bounds()[1] - 1
		paint_piece(held_piece, Vector2i(-9 - holdOffset, held_piece.dimensions().y - held_piece.bottom()), $"Next Queue and Hold/Hold Queue", 1, false)

func paint_piece(p: Piece, spawn: Vector2i, targetTiles = $field, layer = active_layer, clearField = true):
	# print(spawn.x, spawn.y)
	if clearField:
		targetTiles.clear_layer(layer)
	var color = p.piece_color
	for m in p.piece_blocks:
		# print(spawn.x)
		var mX = m[0] + spawn.x
		var mY = m[1] + spawn.y
		targetTiles.set_cell(layer, Vector2i(mX, mY), 1, Vector2i(color, 0))
		
func update_gravity(t):
# to return a boolean if the row below any block in active piece is not occupied, as well as drop the piece if needed.
	var gFactor = 1
	if Input.is_action_pressed("down"):
		gFactor = fast_drop_factor
	gravity_Count += t*gravity*gFactor
	# print(gravity_Count)
	while gravity_Count >= 1:
		gravity_Count -= 1
		activePos += Vector2i.DOWN
		lastAction = 1
		
func rotate_piece(direction: int, p: Piece = active_piece):
	var pWidth = p.dimensions()[rotIndex % 2]
	print("width ", pWidth)
	var kicks = null
	if p.piece_isSquare and pWidth % 2 == 0:
		kicks = rotationTable.kickTableSquare
		#print("even width square rotation")
	elif pWidth >= 2 and pWidth <= 3:
		kicks = rotationTable.kickTable3
		#print("3x3 rotation")
	elif pWidth >= 4:
		kicks = rotationTable.kickTable5
		#print("5x5 rotation")
	var targetPiece = Piece.new()
	var destination: Array = []
	var targetIndex = rotIndex + direction
	if targetIndex > 3:
		targetIndex -= 4
	if targetIndex < 0:
		targetIndex += 4
	print(targetIndex)
	destination = rotationTable.rotation(p, direction)
	
	targetPiece.piece_blocks = destination
	var targetPos = Vector2i(activePos)
	for k in range(len(kicks[rotIndex])):
		var baseOffset = kicks[rotIndex][k]
		var targetOffset = kicks[targetIndex][k]
		var kickPos = targetPos + baseOffset - targetOffset
		print(rotIndex, "-", targetIndex, " kick ", k+1, " ", baseOffset - targetOffset, " from pos ",activePos, " to pos ", kickPos)
		if !fieldCollision(targetPiece, kickPos, Vector2i(0,0)):
			p.piece_blocks = targetPiece.piece_blocks
			activePos = kickPos
			rotIndex = targetIndex
			lastAction = 3
			return baseOffset - targetOffset
	return Vector2i.ZERO

func copy_piece(oldPiece: Piece):
	var newPiece = Piece.new()
	newPiece.piece_name = oldPiece.piece_name
	newPiece.piece_blocks = oldPiece.piece_blocks
	newPiece.piece_color = oldPiece.piece_color
	newPiece.piece_isSquare = oldPiece.piece_isSquare
	return newPiece

func piece_shadow(piece: Piece):
	var shadow = copy_piece(piece)
	shadow.piece_color = 0
	var shadowPos = Vector2i.ZERO
	shadowPos += activePos
	while !fieldCollision(shadow, shadowPos, Vector2i.DOWN):
		shadowPos += Vector2i.DOWN
	paint_piece(shadow, shadowPos, $field, 2, true)
	
func hold_piece(piece: Piece):
	var pCopy = copy_piece(piece)
	if held_piece == null:
		$block.piece_pick()
		active_piece = copy_piece(queue[0])
	else:
		active_piece = copy_piece(held_piece)
	
	holdUsed = true
	rotIndex = 0
	spawn_piece(active_piece)
	
	held_piece = copy_piece(pCopy)
	gravity_Count = 0
	update_queue_display()
	pass
	
func instant_drop():
	while !fieldCollision(active_piece, activePos, Vector2i.DOWN):
		activePos += Vector2i.DOWN
	paint_piece(active_piece, activePos, $field)
		
func place_piece(piece: Piece):
	for m in piece.piece_blocks:
		$field.set_cell(board_layer, activePos + m, 1, Vector2i(piece.piece_color, 0))
	global_Delay += spawn_delay
	lastDelay = 1
	$field.clear_layer(2)
	$field.clear_layer(1)
		
func clear_lines():
	#print("Piece Placed, starting row check")
	lastPieceClears = 0
	var rowClears = []
	for r in range(rows-1, rows * -1.5, -1):
		#print("Checking Row ", r)
		var cellCount = 0
		for c in range(columns):
			if $field.get_cell_source_id(board_layer,Vector2i(c, r)) != -1:
				cellCount += 1
			if cellCount == columns:
				lastPieceClears += 1
				rowClears.append(r)
				for col in range(columns):
					$field.erase_cell(board_layer, Vector2i(col, r))
	$"..".linesCleared += lastPieceClears
	return rowClears

func drop_rows(clears: Array):
	var atlas
	var dropAmount = 0
	#print("dropping rows!")
	for r in range(rows, rows * -1.5, -1):
		if dropAmount > 0:
			for c in range(columns):
				atlas = $field.get_cell_atlas_coords(board_layer, Vector2i(c, r))
				#print("Atlas at cell ", Vector2i(c, r), "is ", atlas)
				$field.set_cell(board_layer, Vector2i(c, r + dropAmount), 1, atlas)
				$field.erase_cell(board_layer, Vector2i(c, r))
		if clears != []:
			if r == clears[0]:
				clears.pop_at(0)
				dropAmount += 1

func spawn_piece(piece: Piece):
	rotIndex = 0
	var rotOffset: Vector2i = Vector2i.ZERO
	var aX = pieceX
	var aY = pieceY - active_piece.bottom()
	activePos = Vector2i(aX, aY)
	if Input.is_action_pressed("hold") and !holdUsed:
		return hold_piece(piece)
	if Input.is_action_pressed("rot ccw") and Input.is_action_pressed("rot cw"):
		#print("both rotations held on spawn, no rotation")
		pass
	elif Input.is_action_pressed("rot ccw"):
		#print("ccw held on spawn")
		rotOffset = rotate_piece(-1, active_piece)
		rotatedThisFrame = true
	elif Input.is_action_pressed("rot cw"):
		#print("cw held on spawn")
		rotOffset = rotate_piece(1, active_piece)
		rotatedThisFrame = true
	aX = pieceX + rotOffset.x 
	aY = pieceY - active_piece.bottom() + rotOffset.y
	activePos = Vector2i(aX, aY)
	if fieldCollision(active_piece, activePos, Vector2i.ZERO):
		pass
	update_queue_display()
	lastDelay = 0

func new_game():
	$block.reset_pieces()
	$"Next Queue and Hold/Next Queue".clear()
	$"Next Queue and Hold/Hold Queue".clear()
	$field.clear()
	queue = $block.piece_queue
	active_piece = copy_piece(queue[0])
	held_piece = null
	holdUsed = false
	lastDelay = 4
	global_Delay = 3
	draw_matrix(columns, rows)

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotatedThisFrame = false
	var input_map = []
	if active_piece != null:
		input_map.append(active_piece.piece_name)
	if Input.is_action_pressed("inst drop"):
		input_map.append("inst drop")
	if Input.is_action_pressed("rot ccw"):
		input_map.append("rot ccw")
	if Input.is_action_pressed("rot cw"):
		input_map.append("rot cw")
	if Input.is_action_pressed("hold"):
		input_map.append("hold")
	if global_Delay > 0:
		global_Delay -= delta
		#print(global_Delay)
		return global_Delay
	global_Delay = 0
	if linesCleared != []:
		drop_rows(linesCleared)
		
	#print(lastDelay)

	if lastDelay != 0:
		if lastDelay != 3:
			active_piece = copy_piece(queue[0])
		spawn_piece(active_piece)

	if !fieldCollision(active_piece, activePos, Vector2i.DOWN):
		update_gravity(delta)
	if Input.is_action_just_pressed("inst drop"):
		#print("instant dropping!")
		instant_drop()
		holdUsed = false
		#print("placing piece!")
		place_piece(active_piece)
		gravity_Count = 0
		#print("checking line clears!")
		linesCleared = clear_lines()
		if linesCleared != []:
			global_Delay += clear_delay
		#print("resetting active piece!")
		$block.piece_pick()
		active_piece = Piece.new()
		
		return global_Delay
		
	var DAS = $"..".autoshift(delta, active_piece, activePos)
	activePos += DAS
	if DAS != Vector2i.ZERO:
		lastAction = 2
	
	if Input.is_action_just_pressed("rot cw") and !rotatedThisFrame:
		rotate_piece(1)
		rotatedThisFrame = true
	if Input.is_action_just_pressed("rot ccw") and !rotatedThisFrame:
		rotate_piece(-1)
		rotatedThisFrame = true
	
	if Input.is_action_just_pressed("hold") and !holdUsed:
		hold_piece(queue[0])
	
	paint_piece(active_piece, activePos, $field)
	piece_shadow(active_piece)
	#print("timestamp: ", $"..".timeElapsed, " ", input_map)

