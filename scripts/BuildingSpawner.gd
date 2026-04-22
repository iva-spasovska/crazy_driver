extends Node3D

const SPAWN_Z = -180.0
const DESPAWN_Z = 30.0
const SPAWN_INTERVAL_Z = 7.0

const LEFT_X = -14.0
const RIGHT_X = 14.0

var _buildings: Array = []

func _ready():
	for i in range(26):
		_spawn_pair(-i * SPAWN_INTERVAL_Z)

func _spawn_pair(z: float):
	_spawn_building(LEFT_X, z)
	_spawn_building(RIGHT_X, z)

func _spawn_building(x: float, z: float):
	var building = _create_building()
	building.position = Vector3(x, 0, z)
	add_child(building)
	_buildings.append(building)

func _create_building() -> Node3D:
	var root = Node3D.new()

	var width = randf_range(4.0, 8.0)
	var depth = randf_range(4.0, 8.0)
	var height = randf_range(5.0, 22.0)

	# Building body
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(width, height, depth)
	body.mesh = box
	body.position.y = height / 2.0
	var mat = StandardMaterial3D.new()
	var colors = [
		Color(0.55, 0.50, 0.45),
		Color(0.40, 0.45, 0.55),
		Color(0.60, 0.55, 0.50),
		Color(0.35, 0.40, 0.45),
		Color(0.50, 0.48, 0.52),
		Color(0.62, 0.58, 0.50),
	]
	mat.albedo_color = colors[randi() % colors.size()]
	body.material_override = mat
	root.add_child(body)

	var win_cols_front = int(width / 1.5)
	var win_cols_side = int(depth / 1.5)
	var win_rows = int(height / 2.5)

	# Front face windows (facing road)
	for row in range(win_rows):
		for col in range(win_cols_front):
			if randf() < 0.25:
				continue
			var win = MeshInstance3D.new()
			var wm = BoxMesh.new()
			wm.size = Vector3(0.6, 0.7, 0.1)
			win.mesh = wm
			var wmat = StandardMaterial3D.new()
			if randf() < 0.6:
				wmat.albedo_color = Color(1.0, 0.95, 0.7)
				wmat.emission_enabled = true
				wmat.emission = Color(1.0, 0.9, 0.5)
				wmat.emission_energy_multiplier = 0.8
			else:
				wmat.albedo_color = Color(0.1, 0.12, 0.15)
			win.material_override = wmat
			win.position = Vector3(
				-width / 2.0 + 1.0 + col * 1.5,
				1.5 + row * 2.5,
				depth / 2.0 + 0.05
			)
			root.add_child(win)

	# Back face windows
	for row in range(win_rows):
		for col in range(win_cols_front):
			if randf() < 0.25:
				continue
			var win = MeshInstance3D.new()
			var wm = BoxMesh.new()
			wm.size = Vector3(0.6, 0.7, 0.1)
			win.mesh = wm
			var wmat = StandardMaterial3D.new()
			if randf() < 0.6:
				wmat.albedo_color = Color(1.0, 0.95, 0.7)
				wmat.emission_enabled = true
				wmat.emission = Color(1.0, 0.9, 0.5)
				wmat.emission_energy_multiplier = 0.8
			else:
				wmat.albedo_color = Color(0.1, 0.12, 0.15)
			win.material_override = wmat
			win.position = Vector3(
				-width / 2.0 + 1.0 + col * 1.5,
				1.5 + row * 2.5,
				-depth / 2.0 - 0.05
			)
			root.add_child(win)

	# Right side face windows
	for row in range(win_rows):
		for col in range(win_cols_side):
			if randf() < 0.25:
				continue
			var win = MeshInstance3D.new()
			var wm = BoxMesh.new()
			wm.size = Vector3(0.1, 0.7, 0.6)
			win.mesh = wm
			var wmat = StandardMaterial3D.new()
			if randf() < 0.6:
				wmat.albedo_color = Color(1.0, 0.95, 0.7)
				wmat.emission_enabled = true
				wmat.emission = Color(1.0, 0.9, 0.5)
				wmat.emission_energy_multiplier = 0.8
			else:
				wmat.albedo_color = Color(0.1, 0.12, 0.15)
			win.material_override = wmat
			win.position = Vector3(
				width / 2.0 + 0.05,
				1.5 + row * 2.5,
				-depth / 2.0 + 1.0 + col * 1.5
			)
			root.add_child(win)

	# Left side face windows
	for row in range(win_rows):
		for col in range(win_cols_side):
			if randf() < 0.25:
				continue
			var win = MeshInstance3D.new()
			var wm = BoxMesh.new()
			wm.size = Vector3(0.1, 0.7, 0.6)
			win.mesh = wm
			var wmat = StandardMaterial3D.new()
			if randf() < 0.6:
				wmat.albedo_color = Color(1.0, 0.95, 0.7)
				wmat.emission_enabled = true
				wmat.emission = Color(1.0, 0.9, 0.5)
				wmat.emission_energy_multiplier = 0.8
			else:
				wmat.albedo_color = Color(0.1, 0.12, 0.15)
			win.material_override = wmat
			win.position = Vector3(
				-width / 2.0 - 0.05,
				1.5 + row * 2.5,
				-depth / 2.0 + 1.0 + col * 1.5
			)
			root.add_child(win)

	# Rooftop detail
	if randf() < 0.5:
		var detail = MeshInstance3D.new()
		var dm = BoxMesh.new()
		dm.size = Vector3(randf_range(0.8, 2.0), randf_range(0.5, 2.0), randf_range(0.8, 2.0))
		detail.mesh = dm
		var dmat = StandardMaterial3D.new()
		dmat.albedo_color = Color(0.3, 0.3, 0.35)
		detail.material_override = dmat
		detail.position.y = height + dm.size.y / 2.0
		root.add_child(detail)

	return root

func _process(delta: float):
	if not GameManager.is_running:
		return

	for building in _buildings:
		building.position.z += GameManager.current_speed * delta

	var to_remove = []
	for building in _buildings:
		if building.position.z > DESPAWN_Z:
			to_remove.append(building)
	for building in to_remove:
		_buildings.erase(building)
		building.queue_free()

	var frontmost_z = 0.0
	for building in _buildings:
		if building.position.z < frontmost_z:
			frontmost_z = building.position.z
	while frontmost_z > SPAWN_Z:
		frontmost_z -= SPAWN_INTERVAL_Z
		_spawn_pair(frontmost_z)
