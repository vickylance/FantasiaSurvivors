extends Node2D

@export_range(1, 1000) var frequency := 8.0
@export_range(1, 1000) var amplitude := 100.0
@export_range(1, 1000) var initial_boost := 150
@export_range(1, 1000) var speed := 150
@export_range(0, 360) var wave_offset_deg := 0.0
@export_range(1, 1000) var length_multiplier := 15.0
@export var num_of_points := 1200
@export var wave_starting_point := Vector2(50, 150)
var time: float = 0

@onready var line := $Line as Line2D
var points: Array[Vector2] = []

func _physics_process(delta: float) -> void:
	time += delta
	wave_offset_deg = wave_offset_deg
#	var movement = cos(time * frequency) * ((amplitude * time) + initial_boost)
	var movement := sin(time * frequency + wave_offset_deg) * ((amplitude * time) + initial_boost)
	position.y += movement * delta
	position.x += speed * delta
	
	points.append(global_position)
	line.points = points

