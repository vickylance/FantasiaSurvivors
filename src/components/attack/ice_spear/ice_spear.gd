extends Area2D

var level = 1
var hp = 1
var speed = 150
var damage = 5
var knock_back = 100
var attack_size = 1.0

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
			hp = 2
			speed = 150
			damage = 5
			knock_back = 100
			attack_size = 1.0
	
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
