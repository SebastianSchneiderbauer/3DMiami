extends VBoxContainer

@onready var resolution_option_button = $Resolution_OptionButton
@onready var full_screen_check_box = $FullScreen_CheckBox
@onready var scale_label = $ScaleBox/ScaleLabel
@onready var scale_slider = $ScaleBox/ScaleSlider
@onready var fsr_options = $FSROptions
@onready var vsync_checkbox = $vsync_checkbox
@onready var screen_selector = $Screen_Selector
@onready var scale_box = $ScaleBox
@onready var scaler = $Scaler

var loaded:bool = false

var Resolutions: Dictionary = {"3840x2160":Vector2i(3840,2160),
								"2560x1440":Vector2i(2560,1080),
								"1920x1080":Vector2i(1920,1080),
								"1600x900":Vector2i(1600,900),
								"1536x864":Vector2i(1536,864),
								"1440x900":Vector2i(1440,900),
								"1366x768":Vector2i(1366,768),
								"1280x720":Vector2i(1280,720),
								"1024x600":Vector2i(1024,600),
								"800x600": Vector2i(800,600)}

func _ready():
	Add_Resolutions()
	Check_Variables()
	Get_Screens()
	_on_scale_slider_value_changed(scale_slider.value)
	SaveManager.save_data_update.connect(_on_savedata_update)

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and visible:
		get_parent().hide()
	
	if SaveManager.loaded and not loaded:
		scaler._select_int(SaveManager.get_data("scaler"))
		_on_scaler_item_selected(SaveManager.get_data("scaler"))
		
		if SaveManager.get_data("scaler") == 1:
			scale_slider.value = SaveManager.get_data("scalerStrength")
			_on_scale_slider_value_changed(SaveManager.get_data("scalerStrength"))
		elif SaveManager.get_data("scaler") == 2:
			fsr_options._select_int(SaveManager.get_data("fsrStrength"))
			_on_fsr_options_item_selected(SaveManager.get_data("fsrStrength"))
		
		full_screen_check_box.set_pressed(SaveManager.get_data("fullScreen"))
		_on_full_screen_check_box_toggled(SaveManager.get_data("fullScreen"))
		
		vsync_checkbox.set_pressed(SaveManager.get_data("VSYNC"))
		_on_vsync_checkbox_toggled(SaveManager.get_data("VSYNC"))
		
		screen_selector._select_int(SaveManager.get_data("defaultScreen"))
		_on_screen_selector_item_selected(SaveManager.get_data("defaultScreen"))
		
		loaded = true

func _on_savedata_update():
	scaler._select_int(SaveManager.get_data("scaler"))
	_on_scaler_item_selected(SaveManager.get_data("scaler"))
	
	if SaveManager.get_data("scaler") == 1:
		scale_slider.value = SaveManager.get_data("scalerStrength")
		_on_scale_slider_value_changed(SaveManager.get_data("scalerStrength"))
	elif SaveManager.get_data("scaler") == 2:
		fsr_options._select_int(SaveManager.get_data("fsrStrength"))
		_on_fsr_options_item_selected(SaveManager.get_data("fsrStrength"))
	
	full_screen_check_box.set_pressed(SaveManager.get_data("fullScreen"))
	_on_full_screen_check_box_toggled(SaveManager.get_data("fullScreen"))
	
	vsync_checkbox.set_pressed(SaveManager.get_data("VSYNC"))
	_on_vsync_checkbox_toggled(SaveManager.get_data("VSYNC"))
	
	screen_selector._select_int(SaveManager.get_data("defaultScreen"))
	_on_screen_selector_item_selected(SaveManager.get_data("defaultScreen"))

func Check_Variables():
	var _window = get_window()
	var mode = _window.get_mode()
	
	if mode == Window.MODE_FULLSCREEN:
		resolution_option_button.set_disabled(true)
		full_screen_check_box.set_pressed_no_signal(true)
		
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		vsync_checkbox.set_pressed_no_signal(true)

func Set_Resolution_Text():
	var Resolution_Text = str(get_window().get_size().x)+"x"+str(get_window().get_size().y)
	resolution_option_button.set_text(Resolution_Text)
	
	scale_slider.set_value_no_signal(100.00)
	_on_scale_slider_value_changed(100.00)
	
func Add_Resolutions():
	var Current_Resolution = get_window().get_size()
	var ID = 0
	
	for r in Resolutions:
		resolution_option_button.add_item(r, ID)
		
		if Resolutions[r] == Current_Resolution:
			resolution_option_button.select(ID)
		
		ID += 1

func _on_option_button_item_selected(index):
	var ID = resolution_option_button.get_item_text(index)
	get_window().set_size(Resolutions[ID])
	Set_Resolution_Text()
	Centre_Window()

func Centre_Window():
	var Centre_Screen = DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2
	var Window_Size = get_window().get_size_with_decorations()
	get_window().set_position(Centre_Screen-Window_Size/2)

func _on_full_screen_check_box_toggled(toggled_on):
	resolution_option_button.set_disabled(toggled_on)
	if toggled_on:
		get_window().set_mode(Window.MODE_FULLSCREEN)
	else:
		get_window().set_mode(Window.MODE_WINDOWED)
		Centre_Window()

func _on_scale_slider_value_changed(value):
	print(value)
	
	var Resolution_Scale = value/100.00
	var Resolution_Text = str(round(get_window().get_size().x*Resolution_Scale))+"x"+str(round(get_window().get_size().y*Resolution_Scale))
	
	scale_label.set_text(str(value)+"% - "+ Resolution_Text)
	get_viewport().set_scaling_3d_scale(Resolution_Scale)
	
func _on_scaler_item_selected(index):
	var _viewport = get_viewport()
	
	match index:
		1:
			_viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
			scale_slider.set_editable(true)
			fsr_options.hide()
			scale_box.show()
		2:
			_viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
			scale_slider.set_editable(false)
			fsr_options.show()
			scale_box.hide()
	
func _on_fsr_options_item_selected(index):
	match index:
		1:
			_on_scale_slider_value_changed(1.00)
		2:
			_on_scale_slider_value_changed(25.00)
		3:
			_on_scale_slider_value_changed(50.00)
		4:
			_on_scale_slider_value_changed(66.00)
		5:
			_on_scale_slider_value_changed(77.00)
		6:
			_on_scale_slider_value_changed(83.00)
		7:
			_on_scale_slider_value_changed(125.00)

func _on_vsync_checkbox_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func Get_Screens():
	var Screens = DisplayServer.get_screen_count()
	
	for s in Screens:
		screen_selector.add_item("Screen: "+str(s))

func _on_screen_selector_item_selected(index):
	var _window = get_window()
	
	var mode = _window.get_mode()

	_window.set_mode(Window.MODE_WINDOWED)
	_window.set_current_screen(index)
	
	if mode == Window.MODE_FULLSCREEN:
		_window.set_mode(Window.MODE_FULLSCREEN)

func _on_return_pressed():
	if scaler.get_selected() != SaveManager.get_data("scaler"):
		SaveManager.set_data("scaler", scaler.get_selected())
	
	if fsr_options.get_selected() != SaveManager.get_data("fsrStrength"):
		SaveManager.set_data("fsrStrength", fsr_options.get_selected())
	
	if scale_slider.value != SaveManager.get_data("scalerStrength"):
		SaveManager.set_data("scalerStrength",scale_slider.value)
	
	if full_screen_check_box.is_pressed() != SaveManager.get_data("fullScreen"):
		SaveManager.set_data("fullScreen",full_screen_check_box.is_pressed())
	
	if vsync_checkbox.is_pressed() != SaveManager.get_data("VSYNC"):
		SaveManager.set_data("VSYNC",vsync_checkbox.is_pressed())
	
	if screen_selector.get_selected() != SaveManager.get_data("defaultScreen"):
		SaveManager.set_data("defaultScreen", screen_selector.get_selected())
	
	SaveManager.save_game()
	
	var ani:AnimationPlayer = get_node("../../AnimationPlayer")
	ani.play("base-show")
