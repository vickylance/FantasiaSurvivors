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

signal hurt(damage: float)


func _ready() -> void:
	assert(self.area_entered.connect(_on_area_entered) == OK)
	assert(disable_timer.timeout.connect(_on_disable_timer_timeout) == OK)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		if area.get("damage") != null:
			match hurt_box_type:
				HurtBoxType.Cooldown:
					collision.call_deferred("set", "disabled", true)
					disable_timer.start()
				HurtBoxType.HitOnce:
					pass
				HurtBoxType.DisableHitBox:
					if area.has_method("temp_disable"):
						area.temp_disable()
			var damage: float = area.damage
			print("DAMAGE", damage)
			hurt.emit(damage)
	pass


func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
	pass


