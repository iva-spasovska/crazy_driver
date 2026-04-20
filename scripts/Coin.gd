extends MeshInstance3D

var _spin: float = 0.0

func _process(delta: float):
	if not GameManager.is_running:
		return

	# Move toward player
	position.z += GameManager.current_speed * delta

	# Spin the coin
	_spin += delta * 3.0
	rotation_degrees.z = _spin * 57.0

	# Despawn if behind player
	if position.z > 10.0:
		queue_free()
