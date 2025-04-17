extends Camera3D

var shakeTime:float
var shakeStrength:float
var shaking:bool

var zoomtime:float
var zooming:bool

var baseZoom:float
var zoomDirection:float
var zoomStrenth:float
var extraZoom:float = 0

var hOffset:float
var vOffset:float

func _ready() -> void:
	get_node("../airdash/SubViewport/airdash").emitting = false
func startZoom(duration:float, strength:float, direction:int):
	zoomtime = duration
	zoomStrenth = strength
	zoomDirection = direction

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
		zooming = true
		zoomtime -= delta
	else:
		zooming = false
	
	zoom(delta)

func shake():
	h_offset -= hOffset
	v_offset -= vOffset
	h_offset = randf_range(-shakeStrength,shakeStrength)
	v_offset = randf_range(-shakeStrength,shakeStrength)
	h_offset += hOffset
	v_offset += vOffset

func zoom(delta):
	if zooming:
		if extraZoom < zoomStrenth and (extraZoom + zoomStrenth*delta*40) < zoomStrenth:
			extraZoom += zoomStrenth*delta*40
		else:
			extraZoom = zoomStrenth
	else:
		if extraZoom > 0 and (extraZoom - zoomStrenth*delta*40) > 0:
			extraZoom -= zoomStrenth*delta*40
		else:
			extraZoom = 0
	
	fov = baseZoom + extraZoom*zoomDirection
