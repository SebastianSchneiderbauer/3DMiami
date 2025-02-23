extends CharacterBody3D

const gravity = Vector3(0,-9.8,0)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var direction = Vector3(0,0,0)
@onready var camera = $camera
var mouse_delta = Vector2.ZERO
var sensitivity = 0.2 # editable from outside

func _process(delta):
	handle_mouse_look()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func handle_mouse_look():
	var rotation_x = -mouse_delta.y * sensitivity
	var rotation_y = -mouse_delta.x * sensitivity
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO
