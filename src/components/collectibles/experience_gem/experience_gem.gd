extends Area2D
class_name ExperienceGem

@export var experience := 1
@export var gems: Array[ExperienceGemRes]

@onready var sprite := $Sprite as Sprite2D
@onready var collision := $Shape as CollisionShape2D
@onready var sound := $CollectedSound as AudioStreamPlayer

var target = null
var speed: float = -1


func _ready() -> void:
	assert(sound.finished.connect(_on_sound_play_finished) == OK)
	gems.sort_custom(func(a, b): return a.gem_value > b.gem_value)
	
	for n in range(gems.size()):
		if experience < gems[n].gem_value:
			sprite.texture = gems[n].gem_sprite
	pass


func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 5 * delta
	pass


func collect() -> int:
	sound.play()
	collision.call_deferred("set", "disabled", false)
	sprite.visible = false
	return experience


func _on_sound_play_finished() -> void:
	queue_free()
	pass


func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false
