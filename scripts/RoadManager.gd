extends Node3D

const CHUNK_LENGTH = 40.0
const DESPAWN_Z = 50.0
const CHUNKS_TOTAL = 8

var _chunks: Array = []

func _ready():
	# Spawn chunks from one behind the player all the way ahead
	for i in range(-1, CHUNKS_TOTAL):
		_spawn_chunk(i * -CHUNK_LENGTH)

func _spawn_chunk(z_pos: float):
	var chunk = _create_road_chunk()
	chunk.position.z = z_pos
	add_child(chunk)
	_chunks.append(chunk)

func _process(delta: float):
	if not GameManager.is_running:
		return

	# Move all chunks toward player
	for chunk in _chunks:
		chunk.position.z += GameManager.current_speed * delta

	# Remove chunks that passed behind the player
	var to_remove = []
	for chunk in _chunks:
		if chunk.position.z > DESPAWN_Z:
			to_remove.append(chunk)
	for chunk in to_remove:
		_chunks.erase(chunk)
		chunk.queue_free()

	# Find the frontmost chunk Z position
	var frontmost_z = 0.0
	for chunk in _chunks:
		if chunk.position.z < frontmost_z:
			frontmost_z = chunk.position.z

	# Keep spawning chunks ahead until we have enough
	while frontmost_z > -(CHUNK_LENGTH * (CHUNKS_TOTAL - 1)):
		frontmost_z -= CHUNK_LENGTH
		_spawn_chunk(frontmost_z)

func _create_road_chunk() -> Node3D:
	var root = Node3D.new()

	# Road surface
	var road = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(12.0, 0.2, CHUNK_LENGTH)
	road.mesh = box
	road.position = Vector3(0, -0.1, -CHUNK_LENGTH / 2.0)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	road.material_override = mat
	root.add_child(road)

	# Lane markings
	for lane_x in [-1.75, 1.75]:
		for d in range(8):
			var dash = MeshInstance3D.new()
			var dm = BoxMesh.new()
			dm.size = Vector3(0.15, 0.21, 2.5)
			dash.mesh = dm
			var dmat = StandardMaterial3D.new()
			dmat.albedo_color = Color(1, 1, 1)
			dash.material_override = dmat
			dash.position = Vector3(lane_x, 0, -4.0 - d * 5.0)
			root.add_child(dash)

	# Curbs
	for side in [-1, 1]:
		var curb = MeshInstance3D.new()
		var cm = BoxMesh.new()
		cm.size = Vector3(0.5, 0.4, CHUNK_LENGTH)
		curb.mesh = cm
		var cmat = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.8, 0.8, 0.85)
		curb.material_override = cmat
		curb.position = Vector3(side * 6.25, 0.1, -CHUNK_LENGTH / 2.0)
		root.add_child(curb)

	# Sidewalks
	for side in [-1, 1]:
		var walk = MeshInstance3D.new()
		var wm = BoxMesh.new()
		wm.size = Vector3(4.0, 0.3, CHUNK_LENGTH)
		walk.mesh = wm
		var wmat = StandardMaterial3D.new()
		wmat.albedo_color = Color(0.55, 0.53, 0.5)
		walk.material_override = wmat
		walk.position = Vector3(side * 8.5, 0.0, -CHUNK_LENGTH / 2.0)
		root.add_child(walk)

	return root
