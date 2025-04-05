extends AudioStreamPlayer3D

func play_pitched_sound():
	var min_pitch = 0.97
	var max_pitch = 1.03
	pitch_scale = randf_range(min_pitch, max_pitch)
	play()
