extends Area2D

var level: int = 1
var hp: int = 9999
var speed: float = 150.0
var damage: float = 5
var knock_back: int = 100
var attack_size: float = 1.0

var last_movement := Vector2.ZERO
var time: float = 0

@export_range(1, 1000) var frequency := 8.0
@export_range(1, 1000) var amplitude := 100.0
@export_range(1, 1000) var amplitude_scale := 2.0
@export_range(1, 1000) var initial_boost := 150
@export_range(1, 1000) var length_multiplier := 15.0
@export var num_of_points := 1200
@export var spawn_point := Vector2(50, 150)

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var timer := $Timer as Timer
@onready var wave_offset = randi_range(0, 4)

signal remove_from_array(object)

func _ready() -> void:
	assert(timer.timeout.connect(_on_timer_timeout) == OK)
	match level:
		1:
			hp = 9999
			speed = 250.0
			damage = 5
			knock_back = 100
			attack_size = 1.0
	
	
	get_parent().rotation = last_movement.angle() # set the rotation of the parent to the player direction
	rotation -= last_movement.angle() # reset the rotation of the sprite irrespective of the parent
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	var final_speed = speed
	speed = speed / 3.0
	initial_tween.tween_property(self, "speed", final_speed, 4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	pass


func _physics_process(delta: float) -> void:
	time += delta
	var movement := sin(time * frequency + wave_offset) * ((amplitude * time * amplitude_scale) + initial_boost)
	position.y += movement * delta
	position.x += speed * delta
	pass


func _on_timer_timeout() -> void:
	remove_from_array.emit(self)
	queue_free()
	pass



