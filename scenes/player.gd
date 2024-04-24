extends Node2D

# Basic Stats for now

var linesCleared: int = 0
var timeElapsed: float = 0
var displayTimer: float = 0
var displayMinutes: int = 0
var timePause: float = 0

var lineGoal = 40

# The framedata for movement.
# The default numbers listed here will be for the "slow" handling setting.
# "Slow" and "fast" handling will be commented next to each assignment.
var shift_delay = 7      	# 10, 7
var shift_repeat = 1      	# 3, 1
var shift_isCharged = false
var shift_counter = 0
var isMoving = false

func roundNum(num, digits):
	return round(num * (10 ** digits))/(10 ** digits)

func autoshift(t, p, pPos):
	var outDirection = Vector2i.ZERO
	var shiftDirection = 0
	if Input.is_action_pressed("left"):
		shiftDirection -= 1
	if Input.is_action_pressed("right"):
		shiftDirection += 1
	
	if Input.is_action_just_pressed("left"):
		shift_isCharged = false
		shift_counter = shift_delay * -1
		if !$matrix.fieldCollision(p, pPos, Vector2i.RIGHT * shiftDirection):
			outDirection = Vector2i.LEFT
	if Input.is_action_just_pressed("right"):
		shift_isCharged = false
		shift_counter = shift_delay * -1
		if !$matrix.fieldCollision(p, pPos, Vector2i.RIGHT * shiftDirection):
			outDirection = Vector2i.RIGHT
	if shiftDirection == 0:
		shift_isCharged = false
		isMoving = false
	else:
		isMoving = true
		shift_counter += t*60
		if shift_counter >= 0:
			shift_counter -= shift_repeat
			shift_isCharged = true
			if $matrix.fieldCollision(p, pPos, Vector2i.RIGHT * shiftDirection):
				shift_counter = 0
			else:
				outDirection = Vector2i.RIGHT * shiftDirection
	#print(outDirection)
	#print(shift_counter)
	return outDirection

func game_reset():
	$matrix.new_game()
	timePause = 3
	linesCleared = 0
	timeElapsed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	game_reset()
	var columns = $matrix.columns
	var rows = $matrix.rows
	$"line count".position = Vector2i(50 + (32*(columns - 5)), 200)
	$timer.position = Vector2i(50 + (32*(columns - 5)), 250)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timePause > 0:
		$timer.text = str("Starting in ", roundNum(timePause, 1))
		timePause -= delta
		return timePause
	$"line count".text = str("Lines: ", linesCleared,"/",lineGoal)
	
	timeElapsed += delta
	if linesCleared < lineGoal:
		displayMinutes = floor(timeElapsed / 60)
		displayTimer = roundNum(timeElapsed - (60 * displayMinutes), 3)
	if displayTimer < 10:
		$timer.text = str("Time: ", displayMinutes, ":0", displayTimer)
	else:
		$timer.text = str("Time: ", displayMinutes, ":", displayTimer)
	
	if Input.is_action_just_pressed("quick reset"):
		game_reset()
