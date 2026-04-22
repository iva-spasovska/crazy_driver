extends Node3D

const LANES = [-3.5, 0.0, 3.5]
const LANE_SWITCH_SPEED = 10.0
const TILT_AMOUNT = 8.0
const JUMP_HEIGHT = 3.5
const JUMP_DURATION = 0.55

var current_lane: int = 1
var target_x: float = 0.0
var is_dead: bool = false
var is_jumping: bool = false
var _input_cooldown: float = 0.0
var _base_y: float = 0.2

@onready var mesh: Node3D = $CarMesh

func _ready():
	target_x = LANES[current_lane]
	position.x = target_x
	position.y = _base_y
	apply_color()

func _process(delta: float):
	if is_dead or not GameManager.is_running:
		return

	_input_cooldown -= delta

	if _input_cooldown <= 0.0:
		if Input.is_action_just_pressed("ui_left"):
			_move_left()
		elif Input.is_action_just_pressed("ui_right"):
			_move_right()

	if Input.is_action_just_pressed("ui_select") and not is_jumping:
		_jump()

	# Smooth lane slide
	position.x = lerp(position.x, target_x, LANE_SWITCH_SPEED * delta)

	# Tilt on lane change
	var x_diff = target_x - position.x
	var tilt_target = 0.0
	if abs(x_diff) > 0.05:
		tilt_target = -sign(x_diff) * TILT_AMOUNT
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z, tilt_target, 10.0 * delta)

	# Collision with traffic — disabled while jumping
	if not is_jumping:
		for car in get_tree().get_nodes_in_group("traffic"):
			if global_position.distance_to(car.global_position) < 2.8:
				die()
				break

	# Collect coins — works even while jumping
	for coin in get_tree().get_nodes_in_group("coins"):
		if global_position.distance_to(coin.global_position) < 1.5:
			_collect_coin(coin)

func _move_left():
	if current_lane > 0:
		current_lane -= 1
		target_x = LANES[current_lane]
		_input_cooldown = 0.15

func _move_right():
	if current_lane < 2:
		current_lane += 1
		target_x = LANES[current_lane]
		_input_cooldown = 0.15

func _jump():
	is_jumping = true

	var speed_factor = GameManager.current_speed / 12.0  # 1.0 at start, ~2.9 at max speed
	var duration = clamp(JUMP_DURATION / speed_factor, 0.35, JUMP_DURATION)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", _base_y + JUMP_HEIGHT, duration)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", _base_y, duration)
	tween.tween_callback(func(): is_jumping = false)
	tween.tween_property(mesh, "scale", Vector3(1.3, 0.6, 1.3), 0.08)
	tween.tween_property(mesh, "scale", Vector3.ONE, 0.15)

func _collect_coin(coin: Node):
	coin.queue_free()
	GameManager.add_coin()

func die():
	if is_dead:
		return
	is_dead = true
	GameManager.end_game()
	var tween = create_tween()
	tween.tween_property(mesh, "rotation_degrees:z", 90.0, 0.3)
	tween.tween_property(mesh, "scale", Vector3(1.2, 0.3, 1.2), 0.3)

func reset():
	is_dead = false
	is_jumping = false
	current_lane = 1
	target_x = LANES[current_lane]
	position = Vector3(0, _base_y, 0)
	mesh.rotation_degrees = Vector3.ZERO
	mesh.scale = Vector3.ONE


func apply_color():
	var color = GameManager.CAR_COLORS[GameManager.selected_color]["color"]
	for child in mesh.get_children():
		if child is MeshInstance3D:
			if child.name == "Body":
				if child.material_override == null:
					child.material_override = StandardMaterial3D.new()
				child.material_override.albedo_color = color
			elif child.name == "Roof":
				if child.material_override == null:
					child.material_override = StandardMaterial3D.new()
				child.material_override.albedo_color = color.darkened(0.2)
