extends CharacterBody2D
class_name Enemy

@export var move_speed := 100.0

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = %Sprite as Sprite2D


func _physics_process(_delta: float) -> void:
	movement()
	sprite_flip(0.1)
	pass


func movement() -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	pass


func sprite_flip(deviation_factor = 0) -> void:
	if velocity.x > deviation_factor:
		sprite.flip_h = true
	elif velocity.x < deviation_factor:
		sprite.flip_h = false
	pass
