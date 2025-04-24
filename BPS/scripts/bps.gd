extends Node3D

var done:bool = false
var max:float
var counter:float = 0
var counterpoint:float = 0.05

@export var particle_count:int = 5
@export var life_time:float = INF
@export var velocity_curve:Curve # Controls how far sideways each particle goes
@export var min_velocity:float = 1.0
@export var max_velocity:float = 5.0

func _ready():
	if not velocity_curve:
		velocity_curve = Curve.new()
		velocity_curve.add_point(Vector2(0, 0))
		velocity_curve.add_point(Vector2(1, 1))

func get_curve_velocity() -> float:
	var t = randf()
	var bias = velocity_curve.sample(t) # Curve outputs [0.0, 1.0]
	return lerp(min_velocity, max_velocity, bias)

func fire():
	for i in range(particle_count):
		var bpsScene = load("res://BPS/scene/bp.tscn")
		var BP = bpsScene.instantiate()
		
		BP.start = global_position
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		var forward = -global_transform.basis.z.normalized()
		var velocity = forward * get_curve_velocity()
		velocity.y = rng.randf_range(3, 10)
		
		BP.direction = velocity
		BP.gravity = Vector3(0, -9.81, 0)
		
		add_child(BP)
		
		rotate_y(360)
