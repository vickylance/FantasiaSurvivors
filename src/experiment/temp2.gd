extends Line2D

@export_range(1, 1000) var frequency := 100.0
@export_range(1, 1000) var amplitude := 60.0
@export_range(1, 1000) var length_multiplier := 15.0
@export var num_of_points := 1200
@export var wave_starting_point := Vector2(50, 150)
@export_range(0, 360) var wave_offset_deg := 0.0
var time: float = 0


func _process(delta: float) -> void:
	time += delta
	var array := []
	for i in range(num_of_points):
		array.append(Vector2(
			wave_starting_point.x + i * length_multiplier,
			wave_starting_point.y + (sin(i * frequency + deg_to_rad(wave_offset_deg)) * amplitude)
		))
	points = array
	pass
