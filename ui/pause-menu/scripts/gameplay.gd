extends Control

var loaded:bool = false

@onready var sens_slider:HSlider = $Options/ScaleBox/ScaleSlider
@onready var sens_label:Label = $Options/ScaleBox/ScaleLabel
@onready var fov_slider:HSlider = $Options/ScaleBox2/FOVSlider
@onready var fov_label:Label = $Options/ScaleBox2/FOVLabel
@onready var crosshair_slider:HSlider = $Options/ScaleBox3/crosshairSlider
@onready var crosshair_label:Label = $Options/ScaleBox3/crosshairLabel
@onready var player = get_node("../../../")
@onready var cam:Camera3D = player.get_node("camera")
@onready var crosshair:TextureRect = get_node("../../crosshair/TextureRect")
@onready var show_crosshair:CheckButton = $"Options/ScaleBox4/show?"
@onready var scale_slider: HSlider = $Options/ScaleBox5/ScaleSlider
@onready var fps_limit_: CheckButton = $"Options/ScaleBox4/fpsLimit?"
@onready var scale_label: Label = $Options/ScaleBox5/ScaleLabel
@onready var color_picker: ColorPicker = $ColorPicker
@onready var highlightColorDisplay: ColorRect = $Options/HBoxContainer/ColorRect
@onready var highlightColorButton: Button = $Options/HBoxContainer/Button

var noLoad:bool = false

func _ready():
	SaveManager.save_data_update.connect(_on_savedata_update)

func _on_savedata_update():
	if noLoad:
		noLoad = false
		return
	
	sens_slider.value = SaveManager.get_data("sensitivity")
	fov_slider.value = SaveManager.get_data("fov")
	show_crosshair.set_pressed(SaveManager.get_data("showCrosshair"))
	crosshair_slider.value = SaveManager.get_data("crosshairScale")
	fps_limit_.set_pressed(SaveManager.get_data("capFPS"))
	scale_slider.value = SaveManager.get_data("FPScap")
	highlightColorDisplay.color = SaveManager.get_data("highlightColor")
	color_picker.color = SaveManager.get_data("highlightColor")

func _on_return_pressed():
	#update save file
	if SaveManager.get_data("sensitivity") != sens_slider.value:
		SaveManager.set_data("sensitivity", sens_slider.value)
	
	if SaveManager.get_data("fov") != fov_slider.value:
		SaveManager.set_data("fov", fov_slider.value)
	
	if bool(SaveManager.get_data("showCrosshair")) != show_crosshair.is_pressed():
		SaveManager.set_data("showCrosshair", show_crosshair.is_pressed())
	
	if SaveManager.get_data("crosshairScale") != crosshair_slider.value:
		SaveManager.set_data("crosshairScale", crosshair_slider.value)
	
	if bool(SaveManager.get_data("capFPS")) != fps_limit_.is_pressed():
		SaveManager.set_data("capFPS", fps_limit_.is_pressed())
	
	if SaveManager.get_data("FPScap") != scale_slider.value:
		SaveManager.set_data("FPScap", scale_slider.value)
	
	if SaveManager.get_data("highlightColor") != color_picker.color:
		SaveManager.set_data("highlightColor", color_picker.color)
	
	noLoad = true
	
	SaveManager.save_game()
	
	get_node("../").inSubMenu = false
	var ani:AnimationPlayer = get_node("../AnimationPlayer")
	ani.play("base-show")

func _process(delta):
	if SaveManager.loaded and not loaded:
		sens_slider.value = SaveManager.get_data("sensitivity")
		fov_slider.value = SaveManager.get_data("fov")
		show_crosshair.set_pressed(SaveManager.get_data("showCrosshair"))
		crosshair_slider.value = SaveManager.get_data("crosshairScale")
		fps_limit_.set_pressed(SaveManager.get_data("capFPS"))
		scale_slider.value = SaveManager.get_data("FPScap")
		highlightColorDisplay.color = SaveManager.get_data("highlightColor")
		color_picker.color = SaveManager.get_data("highlightColor")
		loaded = true
	
	if Input.is_action_just_pressed("ui_cancel") and visible:
		color_picker.hide()
		print("gameplay")
		_on_return_pressed()
	
	if player is CharacterBody3D: #we need to load screen stuff in the menu, so this is evading errors
		#sensi
		sens_label.set_text(str(sens_slider.value))
		player.sensitivity = sens_slider.value
		
		#fov
		fov_label.set_text(str(int(fov_slider.value)))
		cam.baseZoom = fov_slider.value
		cam.fov = cam.baseZoom + cam.extraZoom
		
		#crosshair
		crosshair.scale = Vector2(crosshair_slider.value,crosshair_slider.value)
		crosshair_label.set_text(str(crosshair_slider.value))
		crosshair.visible = show_crosshair.is_pressed()
		crosshair_slider.editable = show_crosshair.is_pressed()
		
		#highlight color
		highlightColorDisplay.color = color_picker.color
	
	#fps-cap
	if fps_limit_.is_pressed():
		Engine.max_fps = scale_slider.value
		scale_label.text = str(int(scale_slider.value))
	else:
		Engine.max_fps = 0
		
	scale_slider.editable = fps_limit_.is_pressed()


func _on_changecolor_pressed() -> void:
	color_picker.visible = !color_picker.visible
