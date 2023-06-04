extends Area2D
class_name ExperienceGem

@export var experience := 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")

var target = null
var speed: float = -1

@onready var sprite := $Sprite as Sprite2D
@onready var collision := $Shape as CollisionShape2D
@onready var sound := $CollectedSound as AudioStreamPlayer


func _ready() -> void:
	assert(sound.finished.connect(_on_sound_play_finished) == OK)
	if experience < 5:
		sprite.texture = spr_green
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red
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
