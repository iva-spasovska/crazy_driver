extends Node3D

const LANES = [-3.5, 0.0, 3.5]
const SPAWN_Z = -60.0
const COIN_SIZE = 0.4

var _timer: float = 0.0
var _next_interval: float = 1.0

func _process(delta: float):
	if not GameManager.is_running:
		return

	_timer += delta
	if _timer >= _next_interval:
		_timer = 0.0
		_next_interval = randf_range(0.8, 2.0)
		_spawn_row()

func _spawn_row():
	# Pick a random lane and spawn 3-5 coins in a line in that lane
	var lane = randi_range(0, 2)
	var count = randi_range(3, 5)
	for i in range(count):
		_spawn_coin(lane, SPAWN_Z - i * 2.0)

func _spawn_coin(lane: int, z: float):
	var coin = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = COIN_SIZE
	cyl.bottom_radius = COIN_SIZE
	cyl.height = 0.15
	coin.mesh = cyl

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.75, 0.0)
	mat.emission_energy_multiplier = 1.5
	coin.material_override = mat

	coin.rotation_degrees.x = 90  # Flat like a coin
	coin.position = Vector3(LANES[lane], 0.8, z)
	coin.add_to_group("coins")

	# Attach movement script
	coin.set_script(load("res://scripts/Coin.gd"))
	add_child(coin)
