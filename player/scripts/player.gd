extends CharacterBody3D

const gravity:Vector3 = Vector3(0,-9.8,0)

const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5

var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
@onready var camera:Camera3D = $camera
var mouse_delta:Vector2 = Vector2.ZERO
var sensitivity:float = 0.1 # editable from outside

var jumps: int = 2
var maxJumps: int = 2

func handle_mouse_look():
	var rotation_x = -mouse_delta.y * sensitivity
	var rotation_y = -mouse_delta.x * sensitivity
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO

func basic_movement():
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

func jump_logic(delta:float):
	if not is_on_floor():
		velocity += gravity * delta
	else:
		jumps = maxJumps
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept"):
		if jumps > 0:
			jumps -= 1
			velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	basic_movement()
	jump_logic(delta)
	move_and_slide()

	
	
	move_and_slide()

func _process(delta):
	handle_mouse_look()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
