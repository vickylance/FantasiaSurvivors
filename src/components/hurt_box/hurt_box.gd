extends Area2D
class_name HurtBox

enum HurtBoxType {
	Cooldown,
	HitOnce,
	DisableHitBox
}
@export var hurt_box_type: HurtBoxType = HurtBoxType.Cooldown

@onready var collision := $Shape as CollisionShape2D
@onready var disable_timer := $DisableTimer as Timer

signal hurt(damage: float, angle: Vector2, knock_back: float)

var hit_once_arrray  = []


func _ready() -> void:
	assert(self.area_entered.connect(_on_area_entered) == OK)
	assert(disable_timer.timeout.connect(_on_disable_timer_timeout) == OK)


func _on_area_entered(area: Area2D) -> void:
	print("enemy hurt Area entered")
	if area.is_in_group("attack"):
		if area.get("damage") != null:
			match hurt_box_type:
				HurtBoxType.Cooldown:
					collision.call_deferred("set", "disabled", true)
					disable_timer.start()
				HurtBoxType.HitOnce:
					if hit_once_arrray.has(area) == false:
						hit_once_arrray.append(area)
						if area.has_signal("remove_from_array"):
							if not area.remove_from_array.is_connected(remove_from_list):
								area.remove_from_array.connect(remove_from_list)
					else:
						return
				HurtBoxType.DisableHitBox:
					if area.has_method("temp_disable"):
						area.temp_disable()
			var damage: float = area.damage
			var angle := Vector2.ZERO
			var knock_back := 1
			if area.get("angle") != null:
				angle = area.angle
			if area.get("knock_back") != null:
				knock_back = area.knock_back
			hurt.emit(damage, angle, knock_back)
	pass


func remove_from_list(object) -> void:
	if hit_once_arrray.has(object):
		hit_once_arrray.erase(object)
	pass


func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
	pass


