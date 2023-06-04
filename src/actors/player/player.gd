extends CharacterBody2D
class_name Player

#@export var BulletScene: PackedScene
@export var move_speed := 150.0
var last_movement := Vector2.UP

@onready var sprite := %Sprite as Sprite2D
@onready var animation_timer := %AnimationTimer as Timer
@onready var health := %Health as Health
@onready var hurt_box := %HurtBox as HurtBox

# Attacks
@export var ice_spear: PackedScene
@export var tornado: PackedScene

# Attack nodes
@onready var ice_spear_timer := %IceSpearTimer as Timer
@onready var ice_spear_attack_timer := %IceSpearAttackTimer as Timer
@onready var tornado_timer := %TornadoTimer as Timer
@onready var tornado_attack_timer := %TornadoAttackTimer as Timer

# IceSpear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 1
var ice_spear_attack_speed: float = 1.5
var ice_spear_level: int = 0

# Tornado
var tornado_ammo: int = 0
var tornado_base_ammo: int = 5
var tornado_attack_speed: float = 3
var tornado_level: int = 1

# Enemy related
var enemies_close = []
@onready var enemy_detection_area := %EnemyDetectionArea as Area2D


#@onready var muzzle := $Muzzle as Marker2D
#@onready var muzzle_flash := $Muzzle/MuzzleFlash as Sprite2D

var bullets: Node


func _ready() -> void:
	assert(hurt_box.hurt.connect(_on_hurt_box_hurt) == OK)
	assert(health.dead.connect(_on_health_dead) == OK)
	
	if not is_instance_valid(get_tree().root.find_child("Bullets", true, false) as Node):
		var newNode = Node.new()
		newNode.name = "Bullets"
		get_tree().root.add_child.call_deferred(newNode)
		bullets = newNode
	else:
		bullets = get_tree().root.find_child("Bullets", true, false) as Node
	pass
	
	assert(enemy_detection_area.body_entered.connect(_on_enemy_entered_detection) == OK)
	assert(enemy_detection_area.body_exited.connect(_on_enemy_exited_detection) == OK)
	
	assert(ice_spear_timer.timeout.connect(_on_ice_spear_timer_timeout) == OK)
	assert(ice_spear_attack_timer.timeout.connect(_on_ice_spear_attack_timer_timeout) == OK)
	
	assert(tornado_timer.timeout.connect(_on_tornado_timer_timeout) == OK)
	assert(tornado_attack_timer.timeout.connect(_on_tornado_attack_timer_timeout) == OK)
	attack()


func _physics_process(_delta: float) -> void:
	control()
	sprite_flip()
	sprite_animation()
	move_and_slide()
	pass


func control() -> void:
#	self.look_at(get_global_mouse_position())
	var input_axis = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if input_axis:
		last_movement = input_axis
		velocity = input_axis * move_speed
	else: # deceleration
		velocity = Vector2(
			move_toward(velocity.x, 0, move_speed),
			move_toward(velocity.y, 0, move_speed))
	pass


func sprite_flip(deviation_factor = 0) -> void:
	if velocity.x > deviation_factor:
		sprite.flip_h = true
	elif velocity.x < deviation_factor:
		sprite.flip_h = false
	pass


func sprite_animation() -> void:
	if velocity != Vector2.ZERO and animation_timer.is_stopped():
		if sprite.frame >= sprite.hframes - 1:
			sprite.frame = 0
		else:
			sprite.frame += 1
		animation_timer.start()
	pass


func _on_hurt_box_hurt(damage: float, _angle: Vector2, _knock_back: float ) -> void:
	health.take_damage(damage)
	pass


func _on_health_dead() -> void:
	queue_free()
	pass


func attack() -> void:
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attack_speed
		if tornado_timer.is_stopped():
			tornado_timer.start()
	pass


func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo
	ice_spear_attack_timer.start()
	pass


func _on_ice_spear_attack_timer_timeout() -> void:
	if ice_spear_ammo > 0:
		var ice_spear_attack = ice_spear.instantiate()
		ice_spear_attack.position = position
		ice_spear_attack.target = get_closest_target()
		ice_spear_attack.level = ice_spear_level
		add_child(ice_spear_attack)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()
	pass


func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_base_ammo
	tornado_attack_timer.start()
	pass


func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.get_child(0).last_movement = last_movement
		tornado_attack.get_child(0).level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_attack_timer.start()
		else:
			tornado_attack_timer.stop()
	pass


func get_random_target() -> Vector2:
	if enemies_close.size() > 0:
		return enemies_close.pick_random().global_position
	else:
		return Vector2.UP


func get_closest_target() -> Vector2:
	if enemies_close.size() > 0:
		return get_closest_enemy().global_position
	else:
		return Vector2.UP


func get_closest_enemy():
	var closest_enemy = null
	var shortest_distance = INF
	for enemy in enemies_close:
		if not is_instance_valid(enemy):
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	return closest_enemy


func _on_enemy_entered_detection(body: Node2D) -> void:
	if not enemies_close.has(body) and body.is_in_group("enemy"):
		enemies_close.append(body)
	pass


func _on_enemy_exited_detection(body: Node2D) -> void:
	if enemies_close.has(body):
		enemies_close.erase(body)
	pass


#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("fire"):
#		shoot()
#	pass


#func shoot() -> void:
#	if not bullets: return
#	var bullet_instance := BulletScene.instantiate()
#	bullet_instance.global_position = muzzle.global_position
#	var target := get_global_mouse_position()
#	var direction_to_target = bullet_instance.global_position.direction_to(target)
#	bullet_instance.rotation = rotation + bullet_instance.rotation
#	bullet_instance.set_direction(direction_to_target)
#	bullet_instance.set_timed_bullet(false)
#	bullet_instance.set_bullet_range(500)
#	bullets.add_child(bullet_instance)
#
#	muzzle_flash.visible = true
#	await get_tree().create_timer(0.1).timeout
#	muzzle_flash.visible = false
#	pass

