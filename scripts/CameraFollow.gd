extends Camera3D

var _target: Node3D

func _ready():
	pass

func _process(delta: float):
	if not _target:
		_target = get_node("../Player")
		return
	var desired = _target.global_position + Vector3(0, 6, 11)
	global_position = lerp(global_position, desired, 8.0 * delta)
	look_at(_target.global_position + Vector3(0, 0, -5), Vector3.UP)
