extends Camera3D

var shakeTime:float
var shakeStrength:float
var shaking:bool

var zoomtime:float
var zoomStrength:float
var zooming:bool

var hOffset:float
var vOffset:float

func startShake(duration:float,strength:float):
	shakeTime = duration
	shakeStrength = strength

func _physics_process(delta: float) -> void:
	if shakeTime > 0:
		shaking = true
		shakeTime -= delta
		shake()
	else:
		shaking = false
		h_offset = 0
		v_offset = 0
		hOffset = 0
		vOffset = 0
	
	if zoomtime > 0:
		zoomtime -= delta

func shake():
	h_offset -= hOffset
	v_offset -= vOffset
	h_offset = randf_range(-shakeStrength,shakeStrength)
	v_offset = randf_range(-shakeStrength,shakeStrength)
	h_offset += hOffset
	v_offset += vOffset

func zoom():
	pass
