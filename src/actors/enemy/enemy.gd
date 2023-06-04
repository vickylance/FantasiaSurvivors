extends CharacterBody2D
class_name Enemy

@export var move_speed := 100.0
@export var knock_back_recovery := 3.5
var knock_back = Vector2.ZERO
@export var death_anim: PackedScene
@export var experience := 1
@export var exp_gem: PackedScene


@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var loot_base := get_tree().get_first_node_in_group("loot")
@onready var sprite: Sprite2D = %Sprite as Sprite2D
@onready var health := %Health as Health
@onready var hurt_box := %HurtBox as HurtBox
@onready var hit_box := %HitBox as HitBox
@onready var hurt_audio := %HurtAudio as AudioStreamPlayer2D

signal remove_from_array(object)


func _ready() -> void:
	assert(hurt_box.hurt.connect(_on_hurt_box_hurt) == OK)
	assert(health.dead.connect(_on_health_dead) == OK)
	pass


func _physics_process(_delta: float) -> void:
	if player == null: return
	
	movement()
	sprite_flip(0.1)
	knock_back_effect()
	move_and_slide()
	pass


func movement() -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	pass


func sprite_flip(deviation_factor := 0.0) -> void:
	if velocity.x > deviation_factor:
		sprite.flip_h = true
	elif velocity.x < deviation_factor:
		sprite.flip_h = false
	pass

func knock_back_effect() -> void:
	knock_back = knock_back.move_toward(Vector2.ZERO, knock_back_recovery)
	velocity += knock_back
	pass


func _on_hurt_box_hurt(damage: float, angle: Vector2, knock_back_amount: float) -> void:
	knock_back = angle * knock_back_amount
	health.take_damage(damage)
	if health.current_hp > 0:
		hurt_audio.play()
	pass


func _on_health_dead() -> void:
	death()
	pass


func death() -> void:
	remove_from_array.emit(self)
	var enemy_death := death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	var new_gem: ExperienceGem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	
	queue_free()
	pass
