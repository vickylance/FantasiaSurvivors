extends CharacterBody2D
class_name Enemy

@export var move_speed := 100.0

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = %Sprite as Sprite2D
@onready var health := %Health as Health
@onready var hurt_box := %HurtBox as HurtBox
@onready var hit_box := %HitBox as HitBox


func _ready() -> void:
	assert(hurt_box.hurt.connect(_on_hurt_box_hurt) == OK)
	assert(health.dead.connect(_on_health_dead) == OK)
	pass


func _physics_process(_delta: float) -> void:
	if player != null:
		movement()
	sprite_flip(0.1)
	pass


func movement() -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	pass


func sprite_flip(deviation_factor := 0.0) -> void:
	if velocity.x > deviation_factor:
		sprite.flip_h = true
	elif velocity.x < deviation_factor:
		sprite.flip_h = false
	pass


func _on_hurt_box_hurt(damage: float) -> void:
	health.take_damage(damage)
	print(health.current_hp)
	pass


func _on_health_dead() -> void:
	queue_free()
	pass
