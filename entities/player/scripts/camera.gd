extends Camera3D

var framecounter:int
var resetPoint:int #the highest Occurency, aka at what point can we reset the counter to not go too high

var shakeTimer:float
var shakeTime:float
var shakeStrength:float
var shakeOccurency:int = 1 #change the value every x´th frame

var zoomtimer:float
var zoomtime:float
var zoomStrength:float
var zoomOccurency:int = 1

func _physics_process(delta: float) -> void:
	framecounter += 1;
