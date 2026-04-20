extends Node3D

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var coin_label: Label = $CanvasLayer/CoinLabel
@onready var game_over_panel: ColorRect = $CanvasLayer/GameOverPanel
@onready var start_panel: ColorRect = $CanvasLayer/StartPanel
@onready var player = $Player
@onready var traffic_spawner = $TrafficSpawner

var _shop: CanvasLayer = null
var _was_running: bool = false

func _ready():
	GameManager.game_over.connect(_on_game_over)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.coins_updated.connect(_on_coins_updated)
	_build_shop_button()

func _build_shop_button():
	var canvas = $CanvasLayer
	var btn = Button.new()
	btn.text = "🎨"
	btn.custom_minimum_size = Vector2(55, 55)
	btn.add_theme_font_size_override("font_size", 28)
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.position = Vector2(-70, 10)
	btn.pressed.connect(_open_shop)
	canvas.add_child(btn)

func _open_shop():
	if _shop:
		return
	_was_running = GameManager.is_running
	GameManager.is_running = false  # Pause

	_shop = load("res://scripts/ShopMenu.gd").new()
	_shop.shop_closed.connect(_close_shop)
	add_child(_shop)

func _close_shop():
	if _shop:
		_shop.queue_free()
		_shop = null
	player.apply_color()
	if _was_running:
		GameManager.is_running = true  # Unpause

func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if not GameManager.is_running and _shop == null:
			_start_game()
	
	if event.is_action_pressed("ui_cancel") and GameManager.is_running:
		GameManager.end_game()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P and _shop == null:
			_open_shop()

func _start_game():
	player.reset()
	player.apply_color()
	for child in traffic_spawner.get_children():
		child.queue_free()
	for coin in get_tree().get_nodes_in_group("coins"):
		coin.queue_free()
	start_panel.hide()
	game_over_panel.hide()
	GameManager.start_game()

func _on_game_over():
	game_over_panel.show()
	
func _on_score_updated(new_score: int):
	score_label.text = "SCORE: %d" % new_score

func _on_coins_updated(total: int):
	coin_label.text = "🪙 %d" % total
