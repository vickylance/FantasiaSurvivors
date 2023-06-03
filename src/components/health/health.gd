extends Node
class_name Health

@export var max_hp := 80.0

@onready var current_hp := max_hp

signal dead()
signal damaged(health: float)

func take_damage(damage: float) -> void:
	if current_hp - damage > 0:
		current_hp -= damage
		damaged.emit(current_hp)
	elif current_hp - damage <= 0:
		current_hp = 0
		dead.emit()
		damaged.emit(current_hp)
	pass
