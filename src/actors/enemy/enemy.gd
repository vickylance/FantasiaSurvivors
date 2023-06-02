extends CharacterBody2D
class_name Enemy

@export var move_speed := 100.0

@onready var player: Player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	movement()
	sprite_flip()
	pass


func movement() -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	pass


func sprite_flip() -> void:
	if velocity.x > 0:
		$Sprite.flip_h = true
	elif velocity.x < 0:
		$Sprite.flip_h = false
	pass
