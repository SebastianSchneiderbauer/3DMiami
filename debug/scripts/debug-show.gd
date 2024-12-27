extends Control

var showdebug: CheckButton

func _ready():
	showdebug = get_parent().get_child(0).get_child(1)

func _physics_process(delta: float):
	visible = showdebug.button_pressed
