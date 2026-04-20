extends Node3D

const LANES = [-3.5, 0.0, 3.5]

var _lane: int = 1
var _speed_offset: float = -5.0

func _ready():
	add_to_group("traffic")
	if has_meta("lane"):
		_lane = get_meta("lane")
	if has_meta("speed_offset"):
		_speed_offset = get_meta("speed_offset")
	position.x = LANES[_lane]

func _process(delta: float):
	if not GameManager.is_running:
		return
	position.z += (GameManager.current_speed + _speed_offset) * delta
	if position.z > 12.0:
		queue_free()
