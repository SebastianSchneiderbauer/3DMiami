extends Control

@onready var fps_label:Label = $fps
@onready var player:CharacterBody3D = get_node("../../")

var counter:float = 0
var wanted:float = 100

var lowest:float = INF

func test():
	const LineRenderer3D = preload("res://addons/LineRenderer/line_renderer.gd")
	
	var line = LineRenderer3D.new()
	
	get_tree().current_scene.add_child(line)
	line.points.clear()
	line.points.append(Vector3(0, 40, 0))
	line.points.append(Vector3(0, 44, 0))
	#line._update_line()


func _ready() -> void:
	Console.add_command("hkinfo",toggle,[],0,"")
	Console.add_command("test",test,[],0,"")

func toggle():
	visible = not visible

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("9"):
		lowest = INF
	
	fps_label.text = "nearby Weapons: (" + str(player.pickUpable.size()) + ") " + str(player.pickUpable)
	fps_label.text += "\nfps: " + str(round(1/delta))
	
	if round(1/delta) < lowest:
		lowest = round(1/delta)
	
	fps_label.text += " (lowest: " + str(lowest) + ")"
	
	fps_label.text += "\nonwall: " + str(player.is_on_wall())
	fps_label.text += "\nonfloor: " +str(player.is_on_floor())
	fps_label.text += "\nglobalPosition: " + str(player.global_position)
	fps_label.text += "\ndirection: " + str(player.direction)
	fps_label.text += "\ninput: " + str(player.input_dir)
	fps_label.text += "\nvelocity: " + str(player.velocity)
	fps_label.text += "\nextra-velocity: " + str(player.extraVelocity)
