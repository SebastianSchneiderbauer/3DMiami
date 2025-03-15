extends Control

var loaded:bool = false

@onready var sens_slider:HSlider = $Options/ScaleBox/ScaleSlider
@onready var sens_label:Label = $Options/ScaleBox/ScaleLabel
@onready var fov_slider:HSlider = $Options/ScaleBox2/FOVSlider
@onready var fov_label:Label = $Options/ScaleBox2/FOVLabel
@onready var crosshair_slider:HSlider = $Options/ScaleBox3/crosshairSlider
@onready var crosshair_label:Label = $Options/ScaleBox3/crosshairLabel
@onready var player:CharacterBody3D = get_node("../../../player")
@onready var cam:Camera3D = player.get_node("camera")
@onready var crosshair:TextureRect = get_node("../../crosshair/TextureRect")
@onready var show_crosshair:CheckButton = $"Options/ScaleBox4/show?"

func _ready():
	SaveManager.save_data_update.connect(_on_savedata_update)

func _on_savedata_update():
	sens_slider.value = SaveManager.get_data("sensitivity")
	fov_slider.value = SaveManager.get_data("fov")
	crosshair_slider.value = SaveManager.get_data("crosshairScale")

func _on_return_pressed():
	#update save file
	if SaveManager.get_data("sensitivity") != sens_slider.value:
		SaveManager.set_data("sensitivity", sens_slider.value)
		
	if SaveManager.get_data("fov") != fov_slider.value:
		SaveManager.set_data("fov", fov_slider.value)
		
	if SaveManager.get_data("crosshairScale") != crosshair_slider.value:
		SaveManager.set_data("crosshairScale", crosshair_slider.value)
	
	SaveManager.save_game()
	
	var ani:AnimationPlayer = get_node("../AnimationPlayer")
	ani.play("base-show")

func _process(delta):
	if SaveManager.loaded and not loaded:
		sens_slider.value = SaveManager.get_data("sensitivity")
		fov_slider.value = SaveManager.get_data("fov")
		crosshair_slider.value = SaveManager.get_data("crosshairScale")
		loaded = true
	
	if Input.is_action_pressed("ui_cancel") and visible:
		hide()
	
	#sensi
	sens_label.set_text(str(sens_slider.value))
	player.sensitivity = sens_slider.value
	
	#fov
	fov_label.set_text(str(fov_slider.value))
	cam.set_fov(fov_slider.value)
	
	#crosshair
	crosshair.scale = Vector2(crosshair_slider.value,crosshair_slider.value)
	crosshair_label.set_text(str(crosshair_slider.value))
	crosshair.visible = show_crosshair.is_pressed()
