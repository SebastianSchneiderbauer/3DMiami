extends CharacterBody3D

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

var toggle = false
var lastToggle = toggle

var sensitivity = 0 # editable from outside
var restrictedMovement = Vector3(0,0,0)
const groundPoundSpeed = -30

var direction = Vector3(0,0,0)
@onready var camera = $Camera3D
var mouse_delta = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _process(delta):
	handle_mouse_look()

func handle_mouse_look():
	# Apply mouse movement to camera and body
	sensitivity = get_parent().get_child(0).sensitivity
	
	var rotation_x = -mouse_delta.y * sensitivity
	var rotation_y = -mouse_delta.x * sensitivity
	
	# Clamp vertical rotation to prevent flipping
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	# Rotate the character body horizontally
	rotation_degrees.y += rotation_y

	# Reset mouse_delta to avoid repeating the motion
	mouse_delta = Vector2.ZERO

func _physics_process(delta): # "main"
	if lastToggle != toggle:
		position = get_parent().get_child(0).position
		rotation = get_parent().get_child(0).rotation
		
		get_child(0).position = get_parent().get_child(0).get_child(1).position
		get_child(0).rotation = get_parent().get_child(0).get_child(1).rotation
		get_child(0).set_fov(get_parent().get_child(0).get_child(1).fov)
	
	if toggle:
		get_child(0).current = true
		# Get the input direction and handle movement
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction != Vector3.ZERO:
			# Move in the given direction
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# Stop instantly when no input is given
			velocity.x = 0
			velocity.z = 0
		
		if Input.is_action_pressed("dbg-speedup"):
			SPEED = 20
		else:
			SPEED = 5
		
		if Input.is_action_pressed("ui_accept"):
			velocity.y = SPEED
		elif Input.is_action_pressed("shift"):
			velocity.y = -SPEED
		else:
			velocity.y = 0
		
		move_and_slide()
	else:
		get_parent().get_child(0).get_child(1).current = true
	
	lastToggle = toggle
