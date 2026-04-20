extends Node

signal game_over
signal score_updated(score: int)
signal coins_updated(coins: int)

var coins: int = 0
var score: int = 0
var _score_timer: float = 0.0
var is_running: bool = false
var current_speed: float = 12.0
var max_speed: float = 35.0
var speed_increase_rate: float = 0.5
var _game_started: bool = false

var total_coins_ever: int = 0  # Never resets, used for purchases
var owned_colors: Array = [0]  # Player owns the first color by default
var selected_color: int = 0    # Currently active color index

const CAR_COLORS = [
	{"name": "Yellow Cab",   "color": Color(1.0, 0.85, 0.0),  "price": 0},
	{"name": "Hot Red",      "color": Color(0.9, 0.15, 0.15), "price": 30},
	{"name": "Snow White",   "color": Color(0.95, 0.95, 0.95),"price": 50},
	{"name": "Ocean Blue",   "color": Color(0.1, 0.45, 0.95), "price": 70},
	{"name": "Lime Green",   "color": Color(0.2, 0.85, 0.25), "price": 100},
	{"name": "Purple",       "color": Color(0.6, 0.1, 0.9),   "price": 150},
	{"name": "Midnight",     "color": Color(0.08, 0.08, 0.12),"price": 200},
	{"name": "Orange Blaze", "color": Color(1.0, 0.45, 0.05), "price": 300},
]

func _ready():
	pass

func start_game():
	coins = 0
	score = 0
	current_speed = 12.0
	is_running = true
	_game_started = true
	_score_timer = 0.0
	emit_signal("score_updated", score)
	emit_signal("coins_updated", coins)

func end_game():
	if not is_running:
		return
	is_running = false
	_game_started = false
	emit_signal("game_over")

func add_coin():
	coins += 1
	total_coins_ever += 1
	emit_signal("coins_updated", coins)

func _process(delta: float):
	if not is_running:
		return
	current_speed = min(current_speed + speed_increase_rate * delta, max_speed)
	
	_score_timer += delta
	if _score_timer >= 0.5:
		_score_timer = 0.0
		score += 1
		emit_signal("score_updated", score)
