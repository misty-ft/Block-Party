extends Node2D

var new_bag: Array = []
var active_bag: Array = []
var piece_queue: Array = []

func trad_7bag(target_bag):
	# I Piece
	var piece_i = Piece.new()
	piece_i.piece_name = "I"
	piece_i.piece_color = 3
	piece_i.piece_blocks = [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
	target_bag.append(piece_i)
	
	# T Piece
	var piece_t = Piece.new()
	piece_t.piece_name = "T"
	piece_t.piece_color = 4
	piece_t.piece_blocks = [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,-1)]
	target_bag.append(piece_t)
	
	# O Piece
	var piece_o = Piece.new()
	piece_o.piece_isSquare = true
	piece_o.piece_name = "oyes"
	piece_o.piece_color = 2
	piece_o.piece_blocks = [Vector2i(0,0), Vector2i(0,-1), Vector2i(1,0), Vector2i(1,-1)]
	target_bag.append(piece_o)
	
	# S Piece
	var piece_s = Piece.new()
	piece_s.piece_name = "S"
	piece_s.piece_color = 3
	piece_s.piece_blocks = [Vector2i(-1,0), Vector2i(0,0), Vector2i(0,-1), Vector2i(1,-1)]
	target_bag.append(piece_s)
	
	# Z Piece
	var piece_z = Piece.new()
	piece_z.piece_name = "Z"
	piece_z.piece_color = 1
	piece_z.piece_blocks = [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0)]
	target_bag.append(piece_z)
	
	# J Piece
	var piece_j = Piece.new()
	piece_j.piece_name = "J"
	piece_j.piece_color = 1
	piece_j.piece_blocks = [ Vector2i(-1,-1), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0)]
	target_bag.append(piece_j)
	
	# L Piece
	var piece_l = Piece.new()
	piece_l.piece_name = "L"
	piece_l.piece_color = 3
	piece_l.piece_blocks = [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)]
	target_bag.append(piece_l)
	
	# :3 Piece
	var piece_temp = Piece.new()
	piece_temp.piece_name = ":3"
	piece_temp.piece_color = 5
	piece_temp.piece_blocks = [Vector2i(-2,-1), Vector2i(-2,1), Vector2i(1,0), Vector2i(2,-1), Vector2i(1,-2), Vector2i(0,-2), Vector2i(2,1), Vector2i(1,2), Vector2i(0,2)]
	#target_bag.append(piece_temp)
	
func add_to_bag(newPiece:Piece):
	new_bag.append(newPiece)

func remove_from_bag(pieceName: String):
	for i in range(len(new_bag)):
		if new_bag[i].piece_name == pieceName:
			new_bag.pop_at(i)
			break

func remove_id(ID: int):
	if (abs(ID) >= 0 and abs(ID) <= len(new_bag)):
		new_bag.pop_at(ID)

func reset_pieces():
	new_bag = []
	active_bag = []
	piece_queue = []
	trad_7bag(new_bag)
	active_bag = new_bag.duplicate()
	while len(piece_queue)<= 10:
		var bagSelect = randi_range(0,len(active_bag)-1)
		var n = give_piece(active_bag, bagSelect)
		#print(n.piece_name)
		piece_queue.append(n)
		if active_bag == []:
			active_bag = new_bag.duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_pieces()
	
func give_piece(target_bag:Array, bagpos:int = -1):
	var pieceGet = target_bag.pop_at(bagpos)
	return pieceGet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	while len(piece_queue)<= 10:
		var bagSelect = randi_range(0,len(active_bag)-1)
		var n = give_piece(active_bag, bagSelect)
		piece_queue.append(n)
		if active_bag == []:
			active_bag = new_bag.duplicate()

func piece_pick():
	return piece_queue.pop_front()


