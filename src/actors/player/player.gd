extends CharacterBody2D
class_name Player

@export var move_speed := 150.0
var last_movement := Vector2.UP

@onready var sprite := %Sprite as Sprite2D
@onready var animation_timer := %AnimationTimer as Timer
@onready var health := %Health as Health
@onready var hurt_box := %HurtBox as HurtBox

# Collectibles
@onready var grab_area := %GrabArea as Area2D
@onready var collect_area := %CollectArea as Area2D
@onready var experience := %Experience as Experience

# Attacks
@export var ice_spear: PackedScene
@export var tornado: PackedScene
@export var javelin: PackedScene

# Attack nodes
@onready var ice_spear_timer := %IceSpearTimer as Timer
@onready var ice_spear_attack_timer := %IceSpearAttackTimer as Timer
@onready var tornado_timer := %TornadoTimer as Timer
@onready var tornado_attack_timer := %TornadoAttackTimer as Timer
@onready var javelin_base := %JavelinBase as Node2D

# IceSpear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 0
var ice_spear_attack_speed: float = 1.5
var ice_spear_level: int = 0

# Tornado
var tornado_ammo: int = 0
var tornado_base_ammo: int = 0
var tornado_attack_speed: float = 3
var tornado_level: int = 0

# Javelin
var javelin_ammo: int = 1
var javelin_level: int = 1


# Enemy related
var enemies_close = []
@onready var enemy_detection_area := %EnemyDetectionArea as Area2D


# Upgrades
var collected_upgrades: Array[UpgradeItem] = []
var upgrade_options: Array = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0


# GUI
@onready var exp_bar := %ExperienceBar as TextureProgressBar
@onready var level_label := %LevelLabel as Label
@onready var level_panel := %LevelUp as Panel
@onready var item_option_list := %UpgradeOptions as VBoxContainer
@onready var sound_level_up := %SoundLevelUp as AudioStreamPlayer
@export var item_upgrade_option: PackedScene


func _ready() -> void:
	assert(hurt_box.hurt.connect(_on_hurt_box_hurt) == OK)
	assert(health.dead.connect(_on_health_dead) == OK)
	
	assert(enemy_detection_area.body_entered.connect(_on_enemy_entered_detection) == OK)
	assert(enemy_detection_area.body_exited.connect(_on_enemy_exited_detection) == OK)
	
	assert(ice_spear_timer.timeout.connect(_on_ice_spear_timer_timeout) == OK)
	assert(ice_spear_attack_timer.timeout.connect(_on_ice_spear_attack_timer_timeout) == OK)
	
	assert(tornado_timer.timeout.connect(_on_tornado_timer_timeout) == OK)
	assert(tornado_attack_timer.timeout.connect(_on_tornado_attack_timer_timeout) == OK)
	
	assert(grab_area.area_entered.connect(_on_grab_area_entered) == OK)
	assert(collect_area.area_entered.connect(_on_collect_area_entered) == OK)
	attack()
	
	assert(experience.level_up.connect(level_up) == OK)
	set_exp_bar()


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
	if javelin_level > 0:
		spawn_javelin()
	pass


func spawn_javelin() -> void:
	var get_javelin_total = javelin_base.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelin_base.add_child(javelin_spawn)
		calc_spawns -= 1
	pass


func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo + additional_attacks
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
	tornado_ammo += tornado_base_ammo + additional_attacks
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


func _on_collect_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
#		if area.is_class("ExperienceGem"):
		var gem_exp = area.collect()
		experience.calculate_experience(gem_exp)
		set_exp_bar()
	pass


func _on_grab_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
#		if area.is_class("ExperienceGem"):
		area.target = self
	pass


func set_exp_bar() -> void:
	exp_bar.value = experience.experience
	exp_bar.max_value = experience.exp_required
	pass


func level_up() -> void:
	sound_level_up.play()
	level_label.text = "Level " + str(experience.level)
	var tween = level_panel.create_tween()
	tween.tween_property(level_panel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	level_panel.visible = true
	
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice: ItemOption = item_upgrade_option.instantiate()
		option_choice.item = get_random_item()
		item_option_list.add_child(option_choice)
		options += 1
	
	get_tree().paused = true
	pass


func upgrade_character(upgrade: UpgradeItem) -> void:
	match upgrade.name:
		"icespear1":
			ice_spear_level = 1
			ice_spear_base_ammo += 1
		"icespear2":
			ice_spear_level = 2
			ice_spear_base_ammo += 1
		"icespear3":
			ice_spear_level = 3
		"icespear4":
			ice_spear_level = 4
			ice_spear_base_ammo += 2
		"icespear5":
			ice_spear_level = 5
			ice_spear_base_ammo += 2
		"tornado1":
			tornado_level = 1
			tornado_base_ammo += 1
		"tornado2":
			tornado_level = 2
			tornado_base_ammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attack_speed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_base_ammo += 1
		"tornado5":
			tornado_level = 5
			tornado_base_ammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"javelin5":
			javelin_level = 5
		"armor1","armor2","armor3","armor4","armor5":
			armor += 1
		"speed1","speed2","speed3","speed4","speed5":
			move_speed += 20.0
		"tome1","tome2","tome3","tome4","tome5":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4","scroll5":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			health.heal(20)
	level_panel_reset()
	get_tree().paused = false
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	experience.calculate_experience(0) # To calculate if left over exp enough to level up further.
	pass


func level_panel_reset() -> void:
	var option_children = item_option_list.get_children()
	for i in option_children:
		i.queue_free()
	level_panel.visible = false
	level_panel.position = Vector2(800, 50)
	pass


func get_random_item() -> UpgradeItem:
	var db_list = []
	for upgrade_item in UpgradeDb.upgrades:
		if upgrade_item in collected_upgrades: # Find already collected upgrades
			pass
		elif upgrade_item in upgrade_options: # If the upgrade is already an option
			pass
		elif upgrade_item.type != "Weapon": # If the item is not a weapon then pass
			pass
		elif upgrade_item.prerequisite.size() > 0: # Check if there are any prerequisites
			for prerequisite_item in upgrade_item.prerequisite:
				if not prerequisite_item in collected_upgrades:
					pass
				else:
					db_list.append(upgrade_item)
		else:
			db_list.append(upgrade_item)
	if db_list.size() > 0:
		var random_item = db_list.pick_random()
		upgrade_options.append(random_item)
		return random_item
	return null
