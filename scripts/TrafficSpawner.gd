extends Node3D

const SPAWN_Z = -180.0
const LANES = [-3.5, 0.0, 3.5]
const CAR_COLORS = [
	Color(0.9, 0.2, 0.2),
	Color(0.2, 0.5, 0.9),
	Color(0.2, 0.8, 0.3),
	Color(0.9, 0.7, 0.1),
	Color(0.7, 0.2, 0.9),
	Color(0.95, 0.95, 0.95),
]

var _timer: float = 0.0
var _next_interval: float = 1.5

func _process(delta: float):
	if not GameManager.is_running:
		return
	_timer += delta
	if _timer >= _next_interval:
		_timer = 0.0
		var speed_factor = (GameManager.current_speed - 12.0) / 23.0
		_next_interval = lerp(randf_range(0.8, 2.2), randf_range(0.4, 1.0), speed_factor)
		_spawn_wave()

func _spawn_wave():
	var lanes = [0, 1, 2]
	lanes.shuffle()
	var count = randi_range(1, 2)
	for i in range(count):
		_spawn_car(lanes[i])

func _spawn_car(lane: int):
	var car = _build_car_mesh(lane)
	car.set_script(load("res://scripts/TrafficCar.gd"))
	car.set_meta("lane", lane)
	car.set_meta("speed_offset", randf_range(-3.0, -8.0))
	car.position = Vector3(LANES[lane], 0.0, SPAWN_Z)
	add_child(car)

func _build_car_mesh(lane: int) -> Node3D:
	var root = Node3D.new()
	var color = CAR_COLORS[randi() % CAR_COLORS.size()]

	# Body
	var body = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = Vector3(1.8, 0.7, 3.8)
	body.mesh = bm
	var bmat = StandardMaterial3D.new()
	bmat.albedo_color = color
	body.material_override = bmat
	body.position.y = 0.55
	root.add_child(body)

	# Roof
	var roof = MeshInstance3D.new()
	var rm = BoxMesh.new()
	rm.size = Vector3(1.6, 0.5, 2.2)
	roof.mesh = rm
	var rmat = StandardMaterial3D.new()
	rmat.albedo_color = color.darkened(0.2)
	roof.material_override = rmat
	roof.position.y = 1.15
	root.add_child(roof)

	# Wheels
	for wp in [Vector3(-1,0.22,1.2), Vector3(1,0.22,1.2), Vector3(-1,0.22,-1.2), Vector3(1,0.22,-1.2)]:
		var w = MeshInstance3D.new()
		var wm = CylinderMesh.new()
		wm.top_radius = 0.35
		wm.bottom_radius = 0.35
		wm.height = 0.28
		w.mesh = wm
		var wmat = StandardMaterial3D.new()
		wmat.albedo_color = Color(0.1, 0.1, 0.1)
		w.material_override = wmat
		w.position = wp
		w.rotation_degrees.z = 90
		root.add_child(w)

	return root
