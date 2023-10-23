extends Area2D

var level = 1

# Base Stats
@export_group("Base Stats")
@export var hp: int = 1
@export var speed: float = 100
@export var damage: int = 5
@export var knock_back: float = 100
@export var attack_size: float = 1.0
@export_group("")

var target := Vector2.ZERO
var angle := Vector2.ZERO

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var timeout_timer := $Timeout

signal remove_from_array(object)

func _ready() -> void:
	assert(timeout_timer.timeout.connect(_on_timeout_timer) == OK)
	assert(self.area_entered.connect(_on_area_entered) == OK)
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 100
			damage = 5
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 2
			speed = 100
			damage = 8
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 2
			speed = 100
			damage = 8
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
		5:
			hp = 2
			speed = 100
			damage = 10
			knock_back = 100
			attack_size = 1.0 * (1 + player.spell_size)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()


func _physics_process(delta: float) -> void:
	position += angle * speed * delta
	pass


func enemy_hit(charge = 1) -> void:
	hp -= charge
	if hp <= 0:
		queue_free()
		remove_from_array.emit(self)
	pass
	

func _on_timeout_timer() -> void:
	queue_free()
	remove_from_array.emit(self)
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemy_hit(1)
	pass
