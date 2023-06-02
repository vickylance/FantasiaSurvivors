extends CharacterBody2D
class_name Player

#@export var BulletScene: PackedScene
@export var move_speed := 150.0

#@onready var muzzle := $Muzzle as Marker2D
#@onready var muzzle_flash := $Muzzle/MuzzleFlash as Sprite2D

var bullets: Node


func _ready() -> void:
	if not is_instance_valid(get_tree().root.find_child("Bullets", true, false) as Node):
		var newNode = Node.new()
		newNode.name = "Bullets"
		get_tree().root.add_child.call_deferred(newNode)
		bullets = newNode
	else:
		bullets = get_tree().root.find_child("Bullets", true, false) as Node
	pass


func _physics_process(_delta: float) -> void:
	control()
	sprite_flip()
	move_and_slide()
	pass


func control() -> void:
#	self.look_at(get_global_mouse_position())
	var input_axis = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if input_axis:
		velocity = input_axis * move_speed
	else: # deceleration
		velocity = Vector2(
			move_toward(velocity.x, 0, move_speed),
			move_toward(velocity.y, 0, move_speed))
	pass

func sprite_flip() -> void:
	if velocity.x > 0:
		$Sprite.flip_h = true
	elif velocity.x < 0:
		$Sprite.flip_h = false
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

