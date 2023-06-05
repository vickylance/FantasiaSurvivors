extends Area2D

var level: int = 1
var hp: int = 9999
var speed: float = 200.0
var damage: float = 10
var knock_back: int = 100
var attack_size: float = 1.0

var paths: int = 1
var attack_speed: float = 5.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_reg := %SpriteReg as Sprite2D
@onready var sprite_attack := %SpriteAttack as Sprite2D
@onready var attack_timer := %AttackTimer as Timer
@onready var change_dir_timer := %ChangeDirection as Timer
@onready var reset_pos_timer := %ResetPosTimer as Timer
@onready var collision := $Shape as CollisionShape2D
@onready var attack_sound := $AttackSound as AudioStreamPlayer2D

signal remove_from_array(object)

func _ready() -> void:
	update_javelin()
	_on_reset_pos_timer_timeout()
	assert(attack_timer.timeout.connect(_on_attack_timer_timeout) == OK)
	assert(change_dir_timer.timeout.connect(_on_change_dir_timer_timeout) == OK)
	pass


func update_javelin() -> void:
	level = player.javelin_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knock_back = 100
			attack_size = 1.0
			paths = 3
			attack_speed = 5.0
	
	scale = Vector2(1, 1) * attack_size
	attack_timer.wait_time = attack_speed
	pass


func _physics_process(delta: float) -> void:
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_diff = global_position - player.global_position
		var return_speed = 20
		if abs(distance_diff.x) > 500 or abs(distance_diff.y):
			return_speed = 100
		position += player_angle * return_speed * delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)
	pass


func _on_attack_timer_timeout() -> void:
	add_paths()
	pass


func _on_change_dir_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			attack_sound.play()
			remove_from_array.emit(self)
		else:
			change_dir_timer.stop()
			attack_timer.start()
			enable_attack(false)
	else:
		change_dir_timer.stop()
		attack_timer.start()
		enable_attack(false)
	pass


func _on_reset_pos_timer_timeout() -> void:
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
	pass


func add_paths() -> void:
	attack_sound.play()
	remove_from_array.emit(self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
	enable_attack(true)
	target = target_array[0]
	process_path()
	pass


func process_path() -> void:
	angle = global_position.direction_to(target)
	change_dir_timer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	pass


func enable_attack(atk := true) -> void:
	if atk:
		collision.call_deferred("set", "disabled", false)
		sprite_reg.visible = false
		sprite_attack.visible = true
	else:
		collision.call_deferred("set", "disabled", true)
		sprite_reg.visible = true
		sprite_attack.visible = false
	pass
