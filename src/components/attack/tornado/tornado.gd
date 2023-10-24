extends Area2D

# Base Stats
@export_group("Base Stats")
@export var level: int = 1
@export var hp: int = 9999
@export var speed: float = 150.0
@export var damage: float = 5
@export var knock_back: int = 100
@export var attack_size: float = 1.0
@export_group("")

var last_movement := Vector2.ZERO
var time: float = 0

@export_group("Tornado Settings")
@export_range(1, 1000) var frequency := 8.0
@export_range(1, 1000) var amplitude := 100.0
@export_range(1, 1000) var amplitude_scale := 2.0
@export_range(1, 1000) var initial_boost := 150
@export_range(1, 1000) var length_multiplier := 15.0
@export var num_of_points := 1200
@export var spawn_point := Vector2(50, 150)
@export_group("")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var timer := $Timer as Timer
@onready var wave_offset = randi_range(0, 4)

signal remove_from_array(object)

func _ready() -> void:
	var res := timer.timeout.connect(_on_timer_timeout) == OK
	assert(res)
	match level:
		1:
			hp = 9999
			speed = 250.0
			damage = 5
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 9999
			speed = 250.0
			damage = 5
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 9999
			speed = 250.0
			damage = 5
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 9999
			speed = 250.0
			damage = 5
			knock_back = 125
			attack_size = 1.0 * (1 + player.spell_size)
		5:
			hp = 9999
			speed = 250.0
			damage = 7
			knock_back = 125
			attack_size = 1.0 * (1 + player.spell_size)
	
	
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



