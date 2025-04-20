extends Control

@onready var fps_label:Label = $fps
@onready var player:CharacterBody3D = get_node("../../")

var counter:float = 0
var wanted:float = 100

var lowest:float = INF

func _process(delta):
	if Input.is_action_just_pressed("0"):
		visible = !visible
	
	if Input.is_action_just_pressed("9"):
		lowest = INF
	
	#fps_label.text = "ctrl pressed: " + str(Input.is_action_pressed("ctrl"))
	fps_label.text = "fps: " + str(round(1/delta))
	
	if round(1/delta) < lowest:
		lowest = round(1/delta)
	
	fps_label.text += " (lowest: " + str(lowest) + ")"
	
	fps_label.text += "\nonwall: " + str(player.is_on_wall())
	fps_label.text += "\nonfloor: " +str(player.is_on_wall())
	fps_label.text += "\nglobalPosition: " + str(player.global_position)
	fps_label.text += "\ndirection: " + str(player.direction)
	fps_label.text += "\ninput: " + str(player.input_dir)
	fps_label.text += "\nvelocity: " + str(player.velocity)
	fps_label.text += "\nextra-velocity: " + str(player.extraVelocity)
	fps_label.text += "\naultimachitui: " + str(player.can_vault())
