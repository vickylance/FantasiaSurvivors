extends Area2D
class_name HitBox

@export var damage := 10.0

@onready var collision := $Shape as CollisionShape2D
@onready var disable_timer := $DisableTimer as Timer


func _ready() -> void:
	assert(disable_timer.timeout.connect(_on_disable_timer_timeout) == OK)
	pass


func temp_disable() -> void:
	collision.call_deferred("set", "disabled", true)
	disable_timer.start()
	pass

func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
	pass
